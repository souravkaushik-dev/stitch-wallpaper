import java.io.File // Import the File class

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0") // Or latest 8.x or 9.x
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use file() to create File objects
rootProject.buildDir = file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/${project.name}") // Use file() here as well
    evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir) // This one is already correct, as delete() accepts a File
}