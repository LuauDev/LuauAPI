﻿using System.Runtime.InteropServices;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Threading;
using System.Net.Http;
using System.Diagnostics;

namespace XenoUI
{
	public partial class ClientsWindow : Window
	{
		public string LuauAPIVersion = "v2.0";

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
		public struct ClientInfo
		{
			public string version;
			public string name;
			public int id;
		}

		[DllImport("LuauAPI.dll", CallingConvention = CallingConvention.Cdecl)]
		private static extern void Initialize();

		[DllImport("LuauAPI.dll", CallingConvention = CallingConvention.Cdecl)]
		private static extern IntPtr GetClients();

		[DllImport("LuauAPI.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
		private static extern void Execute(byte[] scriptSource, string[] clientUsers, int numUsers);

		[DllImport("LuauAPI.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
		private static extern IntPtr Compilable(byte[] scriptSource);

		private readonly DispatcherTimer _timer;
		public List<ClientInfo> ActiveClients { get; private set; } = new();

		public string SupportedVersion { get; private set; } = "";

		private bool _isInjected;

		public ClientsWindow()
		{
			InitializeComponent();
			//LoadSupportedVersion();
			MouseLeftButtonDown += (_, _) => DragMove();

			_timer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(100) };
			_timer.Tick += UpdateClientList;
			_timer.Start();
		}

		/*
		private async void LoadSupportedVersion()
		{
			try
			{
				using var client = new HttpClient();
				string latestVersion = await client.GetStringAsync("https://rizve.us.to/Xeno/LatestVersion");
				if (latestVersion != LuauAPIVersion)
				{
					MessageBox.Show($"The current version {LuauAPIVersion} is outdated.\n\nPlease download the latest version of Xeno ({latestVersion}) here: https://discord.gg/fQNzTw2JXn", "Outdated Xeno version", MessageBoxButton.OK, MessageBoxImage.Warning);
					Application.Current.Shutdown();
				}
				SupportedVersion = await client.GetStringAsync("https://rizve.us.to/Xeno/AcceptedVersion");
			}
			catch (HttpRequestException e)
			{
				MessageBox.Show($"Error fetching versions: {e.Message}");
			}
		}
		*/

		private void UpdateClientList(object sender, EventArgs e)
		{
			var newClients = GetClientsFromDll().ToDictionary(c => c.id);
			checkBoxContainer.Children.OfType<CheckBox>()
				.Where(cb => !newClients.ContainsKey(GetClientId(cb.Content.ToString())))
				.ToList().ForEach(cb => checkBoxContainer.Children.Remove(cb));

			foreach (var client in newClients.Values)
			{
				if (!IsClientListed(client) && !string.IsNullOrWhiteSpace(client.name))
				{
					AddClientCheckBox(client);
				}
			}

			ActiveClients = checkBoxContainer.Children.OfType<CheckBox>()
				.Where(cb => cb.IsChecked == true)
				.Select(cb => new ClientInfo { name = GetClientName(cb.Content.ToString()), id = GetClientId(cb.Content.ToString()) })
				.ToList();
		}

		public void ExecuteScript(string script)
		{
			var clientUsers = ActiveClients.Select(c => c.name).ToArray();
			Execute(Encoding.UTF8.GetBytes(script), clientUsers, clientUsers.Length);
		}

		public string GetCompilableStatus(string script)
		{
			IntPtr resultPtr = Compilable(Encoding.ASCII.GetBytes(script));
			string result = Marshal.PtrToStringAnsi(resultPtr);
			Marshal.FreeCoTaskMem(resultPtr);
			return result;
		}

		private List<ClientInfo> GetClientsFromDll()
		{
			var clients = new List<ClientInfo>();
			IntPtr currentPtr = GetClients();
			while (true)
			{
				var client = Marshal.PtrToStructure<ClientInfo>(currentPtr);
				if (client.name == null) break;
				clients.Add(client);
				currentPtr += Marshal.SizeOf<ClientInfo>();
			}
			return clients;
		}

		private static int GetClientId(string content) => int.Parse(content.Split(", PID: ")[1]);
		private static string GetClientName(string content) => content.Split(", PID: ")[0].Trim();
		private bool IsClientListed(ClientInfo client) => checkBoxContainer.Children.OfType<CheckBox>().Any(cb => cb.Content.ToString() == $"{client.name}, PID: {client.id}");

		private async Task AddClientCheckBox(ClientInfo client)
		{
			if (client.name == "N/A")
			{
				return;
			}
			checkBoxContainer.Children.Add(new CheckBox
			{
				Content = $"{client.name}, PID: {client.id}",
				Foreground = Brushes.White,
				FontFamily = new FontFamily("Franklin Gothic Medium"),
				IsChecked = true,
				Background = Brushes.Black
			});
			while (string.IsNullOrWhiteSpace(SupportedVersion))
			{
				await Task.Delay(5);
			}
		}

		private void buttonClose_Click(object sender, RoutedEventArgs e) => Hide();

		public async void InjectRoblox()
		{
			if (!IsRobloxOpen())
			{
				MessageBox.Show("Roblox is not open. Please start Roblox before injecting.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
				return;
			}

			if (IsInjected())
			{
				MessageBox.Show("Already injected.", "Info", MessageBoxButton.OK, MessageBoxImage.Information);
				return;
			}

			await Task.Run(() => Initialize());
			_isInjected = true;
			MessageBox.Show("Successfully injected.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
		}

		private bool IsRobloxOpen()
		{
			return Process.GetProcessesByName("RobloxPlayerBeta").Any();
		}

		private bool IsInjected()
		{
			return _isInjected;
		}
	}
}
