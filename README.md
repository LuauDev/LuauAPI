> **🌿 LuauAPI is owned by [skidder.lol](https://discord.gg/eknR2BNPdT)**
> 
> **🙏 Thanks for using my source! If you find it helpful, consider giving credit and sharing your support.**

# 🌿 LuauAPI
An executor made for the web version of Roblox.

LuauAPI uses a common method of writing unsigned bytecode into a Roblox core module script to manage execution. It's more stable and flexible than most executors that utilize this method.

## ⚠️ Important Note
If you’re going to use my source code, please **give credit** and respect the license. Don't be like those who have used my entire source code without attribution or have distributed it as their own.

## 🛠️ Build Instructions
1. **Install Prerequisites**:
   - Install [Visual Studio](https://visualstudio.microsoft.com/)
   - Install [vcpkg](https://github.com/microsoft/vcpkg)
   - Install [OpenSSL](https://slproweb.com/download/Win64OpenSSL-3_4_0.exe) (Non-light verison)

2. **Install Dependencies**:
   ```sh
   vcpkg install xxhash zstd
   ```

3. **Build the Project**:
   - Open the `.sln` file with Visual Studio
   - Set build configuration to `Release` and platform to `x64`
   - Click Build > Build Solution (or press F7)
   - Start the project (F5)

⚠️ **Having Issues?** Report them in our [GitHub Issues](https://github.com/LuauDev/LuauAPI/issues)

## 🌟 Features
- **Fast Execution**: Enjoy quick script execution without lag.
- **Multi-Instance Compatibility**: Run multiple instances seamlessly.
- **Script Support**: Executes most scripts, including Lua Armor scripts.
- **Efficient Virtual Filesystem**: Extremely fast and syncs with external files.
- **Performance**: No in-game performance impact and minimal CPU usage.
- **Custom Functions**: Includes functions like HttpSpy, getting the real address of an instance, and setting/getting globals across clients.

### HttpGet Interference
The current method of adding **HttpGet** to `game` may interfere with some scripts, such as [**dex**](https://raw.githubusercontent.com/infyiff/backup/main/dex.lua). To execute dex, run the following script:

```lua
getgenv().game = workspace.Parent
```

This will remove **HttpGet** from `game`. You can also use the modified version of dex made for Xeno inside the released files.

## 📦 Dependencies
This project uses the following libraries:

- [**httplib**](https://github.com/yhirose/cpp-httplib)
- [**xxhash**](https://github.com/Cyan4973/xxHash)
- [**zstd**](https://github.com/facebook/zstd)
- [**openssl**](https://github.com/openssl/openssl)

Dependencies are managed with [**vcpkg**](https://github.com/microsoft/vcpkg). Install them with this command:

```sh
vcpkg install xxhash zstd openssl
```

The proper version of **httplib** is already included in this project.

## 📖 Usage
To use LuauAPI, follow these instructions:

1. **Launch Roblox** and navigate to the desired game.
2. **Open LuauAPI**.
3. **Insert your scripts** into the designated input area.
4. **Execute** the script and enjoy!

### Example Script
Here’s a simple example of a script you might run:

```lua
-- Example script to print Hello, World!
print("Hello, World!")
```

## 🤝 Community Support
Join our community for support, updates, and collaboration:

- **Discord**: [Join our server](https://discord.gg/e8r2mWRA)
- **Issues**: If you encounter any bugs, please report them on [GitHub Issues](https://github.com/LuauAPI/LuauAPI/issues).

## 📜 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
