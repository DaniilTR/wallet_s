allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Не форсируем вычисление Provider на этапе конфигурации и используем set() вместо value()
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    layout.buildDirectory.set(newBuildDir.map { it.dir(project.name) })
}
// Removed project.evaluationDependsOn(":app") to prevent cyclic dependencies.

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
