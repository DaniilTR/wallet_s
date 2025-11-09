package com.cryptowallet.service;

import com.cryptowallet.config.BscConfig;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;
import org.web3j.protocol.core.methods.response.EthGetBalance;
// no-op
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.abi.FunctionEncoder;
import org.web3j.abi.FunctionReturnDecoder;
import org.web3j.abi.TypeReference;
import org.web3j.protocol.core.DefaultBlockParameterName;

import java.math.BigDecimal;
import java.math.BigInteger;
// no-op
import java.util.Collections;
import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class BscService {
    private volatile Web3j web3j;
    private static final int TOKEN_DECIMALS = 8; // фиксируем для упрощения
    // Можно вернуть символ при необходимости из конфига или контракта

    private Web3j client() {
        if (web3j != null) return web3j;
        synchronized (this) {
            if (web3j != null) return web3j;
            for (String url : BscConfig.RPC_URLS) {
                try {
                    Web3j c = Web3j.build(new HttpService(url));
                    c.ethGasPrice().send(); // пробный запрос
                    web3j = c;
                    break;
                } catch (Exception e) {
                    // попробуем следующий URL
                }
            }
            if (web3j == null) {
                throw new RuntimeException("Не удалось подключиться к RPC BSC Testnet");
            }
            return web3j;
        }
    }

    public BigDecimal getNativeBalanceBNB(String addressHex) {
        try {
            EthGetBalance bal = client().ethGetBalance(addressHex, DefaultBlockParameterName.LATEST).send();
            BigInteger wei = bal.getBalance();
            return new BigDecimal(wei).divide(new BigDecimal("1"));
        } catch (Exception e) {
            throw new RuntimeException("Ошибка получения баланса BNB: " + e.getMessage(), e);
        }
    }

    public BigDecimal getTokenBalance(String addressHex) {
        try {
            BigInteger raw = callErc20BalanceOf(BscConfig.TOKEN_CONTRACT, addressHex);
            BigDecimal denom = BigDecimal.TEN.pow(TOKEN_DECIMALS);
            return new BigDecimal(raw).divide(denom);
        } catch (Exception e) {
            throw new RuntimeException("Ошибка получения баланса токена: " + e.getMessage(), e);
        }
    }

    private BigInteger callErc20BalanceOf(String contract, String owner) throws Exception {
    Function f = new Function(
        "balanceOf",
        Collections.singletonList(new Address(owner)),
        Arrays.asList(new TypeReference<Uint256>() {})
    );
    String data = FunctionEncoder.encode(f);
    org.web3j.protocol.core.methods.request.Transaction tx =
        org.web3j.protocol.core.methods.request.Transaction.createEthCallTransaction(
            null,
            contract,
            data
        );
        String value = client().ethCall(tx, DefaultBlockParameterName.LATEST).send().getValue();
        List<?> decoded = FunctionReturnDecoder.decode(value, f.getOutputParameters());
        Uint256 amount = (Uint256) decoded.get(0);
        return amount.getValue();
    }
    
}
