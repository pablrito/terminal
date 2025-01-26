using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Configuration;

 IConfiguration config = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .Build();
            
string? hubUrl = config["AppSettings:hubUrl"];

#pragma warning disable CS8604 // Possible null reference argument.
var connection = new HubConnectionBuilder()
            .WithUrl(hubUrl, options =>
            {
            })
            .Build();
#pragma warning restore CS8604 // Possible null reference argument.

connection.On<string>("ReceiveMessage", (message) =>
{
    Console.WriteLine($"Incomming message : {message}"); 
    connection.InvokeAsync("Notification", connection.ConnectionId, message + " received from " + connection.ConnectionId);
});


try
{
    await connection.StartAsync();
    Console.WriteLine($"Connected to the server, connection Id : {connection.ConnectionId}");
    Console.WriteLine($"Started to listened, press q for quit");

    // Loop for reading commands
    while (true)
    {
        string? input = Console.ReadLine();
        if (!string.IsNullOrWhiteSpace(input) && input.ToLower() == "q")
        {
            await connection.StopAsync();
            Console.WriteLine($"Disconnected to the server");
            Console.WriteLine($"Exiting the application...");
            break;
        }
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Connection closed: {ex.Message}");
}
