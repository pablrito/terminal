using System.Text.Json;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Logging;


var connection = new HubConnectionBuilder()
    .WithUrl("https://automate20250117155727.azurewebsites.net/stock")
    .WithAutomaticReconnect()
    .ConfigureLogging(logging =>
    {
        logging.SetMinimumLevel(LogLevel.Debug);
      
    })
    .Build();

connection.On<string,JsonDocument>("ReceiveStockUpdate", (stock, priceJson) =>
{
    Console.WriteLine($"Stock : {stock} Price : {priceJson.RootElement.GetRawText()}");
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

      
