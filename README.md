# Undervolting
Undervolting decreases CPU voltage and power consumption at a given frequency. This enables higher CPU performance and/or lower power consumption. 

A -120mv offset on the core/cache/uncore was stable on my laptop.  
The idle CPU power consumption decreased from 2.1w to 1.5w (idle voltage from 0.7v to 0.58v).  
Frequency and performance in benchmarks increased by 9% when power consumption is fixed at 60w, the power limit can be reduced to 44w while maintaining the original performance.

When virtualization is enabled, windows blocks access to model-specific registers (MSR) like 0x150 which is needed when undervolting CPUs. When using Windows without hypervisor or Linux, undervolting can also be done within the operating system.

This is an EFI driver that applies the necessary changes each boot before Windows loads and the hypervisor blocks MSRs. It aims to be easy to build compared to other offerings that require the user to build the entirety of EDK-II and various dependencies. Tested with Intel Core 4th gen and 9th gen, but should work with anything 4th gen or newer unless it is blocked by the BIOS, and should work with any operating system as long as the system drive is UEFI/GPT-based.
The release contains a prebuilt EFI shell from [**EDK-II**](https://github.com/tianocore/edk2) for convenience.

How undervolting works and why it got disabled: https://ieeexplore.ieee.org/document/9104908 or DOI 10.1109/MSEC.2020.2990495 

## How to use
1. Get a USB drive, [convert to gpt](https://learn.microsoft.com/en-us/windows-server/storage/disk-management/change-an-mbr-disk-into-a-gpt-disk) and [create a partition](https://support.microsoft.com/en-us/windows/create-and-format-a-hard-disk-partition-bbb8e185-1bda-ecd1-3465-c9728f7d7d2e) with fat32 filesystem.
2. Download the release zip and unzip it to the root of the USB drive.
3. Reboot to the USB drive which contains the efi shell. If secure boot is enabled then it needs to be disabled in the bios.
4. It will show fs0, fs1, etc. and the one that has USB in the name is your USB drive. Assuming it is fs0, type the command ```load fs0:undervolt50.efi``` and press enter for a -50mv offset.
5. Assuming fs1 contains your operating system, run command ```fs1:efi\boot\bootx64``` to boot into the Operating system. 
6. Verify stability by running CPU stress tests, benchmarks, and software that you use. Go to step 3 and repeat with a different offset (e.g. try undervolt70.efi if -50mv was stable, try undervolt30.efi if -50mv was unstable), aim to undervolt by as much as possible while retaining stability. 
7. To apply this change every boot, reboot to the USB drive, if -110mv is the chosen offset run ```cp fs0:undervolt110.efi fs1:efi\boot``` and then ```bcfg driver add 0 fs1:efi\boot\undervolt110.efi "undervolt"```. Power off the computer and power on as usual, now the undervolt will be applied each time you boot your computer.
8. If you wish to remove the  the driver, run ```bcfg driver rm 0``` and ```rm fs1:efi\boot\undervolt110.efi``` in the efi shell.

These prebuilt drivers only undervolt the core, cache, and uncore, with 10mv increments. If you want more precision, want the core and uncore to have different offsets, or want to undervolt the integrate graphics or io, you can build your own efi driver.

## How to build
1. Download undervolt.asm from this repository
2. Build with [**FASM**](https://flatassembler.net/)

    * Download FASM, unzip, and place undervolt.asm into the folder
    * Open undervolt.asm with a text editor and change the five voltage offsets.
    * Open a shell and navigate to the folder (can shift+rightclick open PowerShell window here in windows file explorer)
    * Run command ```./FASM undervolt.asm``` and you should get a undervolt.efi file in the same folder. Copy it to the USB drive and use it just like the other efi files as detailed above.
