# 🌪️ hurr1c4ne

**A next-generation iOS/iPadOS semi-jailbreak research project.**

hurr1c4ne is an experimental project exploring alternative iOS customization,
exploit integration, and Debian package management on supported Apple devices.

The project is written in Objective-C and uses GitHub Actions for automated IPA builds.

> ⚠️ hurr1c4ne is under active development. Features and device compatibility
> are experimental and may change as research progresses.

## 🎯 Goals

- [x] Establish an Objective-C project.
- [x] Use GitHub Actions for automated builds.
- [ ] Create a native UIKit application.
- [ ] Implement the PatchMe interface.
- [ ] Detect the device model, OS version, and build number.
- [ ] Develop a modular compatibility and exploit-backend system.
- [ ] Investigate semi-jailbreak activation and persistence.
- [ ] Develop Debian (.deb) package inspection and management.
- [ ] Investigate compatibility with Sileo and Zebra.
- [ ] Investigate tweak and repository compatibility.
- [ ] Implement diagnostics and recovery handling.

## 📱 Target Platforms

Initial research targets:

- iOS/iPadOS 26.0–27.0.1

Compatibility will be evaluated individually for each OS version, build,
and device model. Inclusion in the target range does not imply that a
working exploit or jailbreak is available.

## 🛠️ Technology

| Component | Technology |
|---|---|
| Programming language | Objective-C |
| UI framework | UIKit |
| Source files | `.h` and `.m` |
| Build automation | GitHub Actions |
| Application format | IPA |
| Package format | Debian `.deb` |

## ⚡ PatchMe

The planned PatchMe workflow will:

1. Detect device and operating-system information.
2. Evaluate available backend compatibility.
3. Select a verified compatible backend, if one exists.
4. Attempt activation when prerequisites are satisfied.
5. Report the capabilities actually obtained.
6. Enable only the features supported by the active environment.

A successful application launch or exploit attempt does not, by itself,
establish that jailbreak-level privileges have been obtained.

## 📦 Package Management

hurr1c4ne aims to investigate Debian package support and compatibility
with existing jailbreak repositories, including:

- Havoc
- Chariz

Sileo and Zebra integration will also be investigated.

Repository access, package downloads, and `.deb` inspection do not
automatically imply that packages can be installed or that their tweaks
will function. Installation and tweak compatibility depend on the
permissions, filesystem access, services, and injection capabilities
available in the target environment.

## 🏗️ Building

hurr1c4ne is intended to be built automatically using GitHub Actions.

1. Open the repository on GitHub.
2. Navigate to **Actions**.
3. Select the project's build workflow.
4. Run the workflow when manual execution is supported.
5. Check the workflow logs for build errors.
6. Download the IPA from the workflow artifacts when a build succeeds
   and artifact uploading is configured.

A successful build produces an application package; it does not establish
that the application can activate a semi-jailbreak on a particular device.

## 🔬 Development Status

**Status:** Early development

The project is being developed incrementally, beginning with the
application foundation, device detection, compatibility checks, and
automated builds.

Exploit support, activation, persistence, package installation, and tweak
compatibility remain subject to implementation and verification.

## ⚠️ Disclaimer

hurr1c4ne is an experimental software research project.

- Compatibility is not guaranteed.
- No particular exploit or jailbreak capability is guaranteed.
- Installing the IPA does not mean the device is jailbroken (this one is here if you’re new to jailbreaking).
- Users should understand the risks before testing experimental software.
- Always maintain a backup of important data.

Use this project only on devices you own or are authorized to test.

## 📄 License

The project license will be specified by its maintainers.
