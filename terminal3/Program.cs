using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Configuration;

IConfiguration config = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();

string? hubUrl = config["AppSettings:hubUrl"];

var connection = new HubConnectionBuilder()
    .WithUrl(hubUrl)
    .WithAutomaticReconnect()
    .Build();

connection.On<Message>("ReceiveMessage", async (message) =>
{
    Console.WriteLine($"Incoming message: {message.type}");
    await connection.InvokeAsync("Notification", connection.ConnectionId, $"{message.type} received from {connection.ConnectionId}");
});

// Reconnecting event
connection.Reconnecting += (error) =>
{
    Console.WriteLine($"Reconnecting... Reason: {error?.Message}");
    return Task.CompletedTask;
};

// Reconnected event
connection.Reconnected += (connectionId) =>
{
    Console.WriteLine($"Reconnected! Connection ID: {connectionId}");
    return Task.CompletedTask;
};

// Closed event
connection.Closed += async (error) =>
{
    Console.WriteLine($"Connection lost: {error?.Message}");
    await Task.Delay(5000);
    try
    {
        await connection.StartAsync();
        Console.WriteLine("Reconnected manually.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Failed to reconnect: {ex.Message}");
    }
};

// Retry connection until successful
while (true)
{
    try
    {
        await connection.StartAsync();
        Console.WriteLine($"Connected to the server, connection Id : {connection.ConnectionId}");
        break;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Failed to connect: {ex.Message}");
        Console.WriteLine("Retrying in 5 seconds...");
        await Task.Delay(5000);
    }
}

// Main loop to read user input
Console.WriteLine("Started listening, press 'q' to quit.");
while (true)
{
    string? input = Console.ReadLine();
    if (!string.IsNullOrWhiteSpace(input) && input.ToLower() == "q")
    {
        await connection.StopAsync();
        Console.WriteLine("Disconnected from the server.");
        break;
    }
}

internal class Message
{
    public string type { get; set; }
}
