allprojects {
    repositories {
        google()
        mavenCentral()
        // usb_serial's serial driver is published only on JitPack. Gradle resolves a
        // library's dependencies with the app's repositories, so JitPack is declared
        // here, once, and only that driver's group may come from it
        // (third_party/usb_serial/PATCHES.md).
        maven("https://jitpack.io") {
            content { includeGroup("com.github.felHR85") }
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

// Every Android library compiles against the app's SDK (Flutter's compileSdk, 36).
// network_info_plus and usb_serial require whatever depends on them to compile
// against 36, and unified_esc_pos_printer still pins 34. compileSdk only decides
// which APIs code may call; how the app behaves on a device is targetSdk's.
// finalizeDsl runs after a library's own build script, so its pin cannot undo this.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension> {
            finalizeDsl { library ->
                if ((library.compileSdk ?: 0) < 36) library.compileSdk = 36
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
