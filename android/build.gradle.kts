import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        extensions.findByType(BaseExtension::class.java)?.let {
            it.compileSdkVersion(36)
        }
        tasks.configureEach {
            if (this is org.jetbrains.kotlin.gradle.tasks.KotlinCompile) {
                kotlinOptions.jvmTarget = "17"
            }
            if (this is JavaCompile) {
                sourceCompatibility = "17"
                targetCompatibility = "17"
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
