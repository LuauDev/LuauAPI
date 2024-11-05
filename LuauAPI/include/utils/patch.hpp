 #pragma once
#include <Windows.h>

inline bool PatchWinTrust() {
    HMODULE hWinTrust = GetModuleHandleA("wintrust.dll");
    if (!hWinTrust) return false;

    FARPROC pWinVerifyTrust = GetProcAddress(hWinTrust, "WinVerifyTrust");
    if (!pWinVerifyTrust) return false;

    // Patch bytes to always return SUCCESS (0)
    unsigned char patch[] = {
        0x33, 0xC0,    // xor eax, eax
        0xC3           // ret
    };

    DWORD oldProtect;
    if (!VirtualProtect(pWinVerifyTrust, sizeof(patch), PAGE_EXECUTE_READWRITE, &oldProtect))
        return false;

    memcpy(pWinVerifyTrust, patch, sizeof(patch));

    VirtualProtect(pWinVerifyTrust, sizeof(patch), oldProtect, &oldProtect);
    return true;
}