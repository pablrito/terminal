using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Configuration;


 IConfiguration config = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .Build();
            
string hubUrl = config["AppSettings:hubUrl"];

    
Console.ForegroundColor = ConsoleColor.Blue;
Console.WriteLine("Welcome to the Terminal App!");
Console.WriteLine("Type 'help' to see available commands.");
Console.WriteLine("Type 'exit' to quit the application.");



  var connection = new HubConnectionBuilder()
            .WithUrl(hubUrl, options =>
            {
                options.Headers["X-Auth-Token"] = config["AppSettings:secret"];  
            })
            .Build();

connection.On<string, string>("ReceiveMessage", (id, message) =>
{
    Console.ForegroundColor = ConsoleColor.Green;
    Console.WriteLine("Incomming message"); 
    Console.WriteLine($"{id}: {message}");
    Console.ForegroundColor = ConsoleColor.Blue;

    connection.InvokeAsync("Notification", connection.ConnectionId, message + " handshake");
    Random random = new Random();
    Thread.Sleep(random.Next(1000, 10000));
    connection.InvokeAsync("Notification", connection.ConnectionId, message + " initiate");
    Thread.Sleep(random.Next(1000, 10000));
    connection.InvokeAsync("Notification", connection.ConnectionId, message + " done");

});

// Loop for reading commands
while (true)
{
    Console.Write("\n> ");
#pragma warning disable CS8600 // Converting null literal or possible null value to non-nullable type.
    string input = Console.ReadLine();
#pragma warning restore CS8600 // Converting null literal or possible null value to non-nullable type.

    // Perform actions based on input
    if (string.IsNullOrWhiteSpace(input))
    {
        Console.WriteLine("Please enter a command.");
    }
    else if (input.ToLower() == "connect")
    {
        try
        {
            await connection.StartAsync();
            Console.WriteLine($"Connected to the server, host id : {connection.ConnectionId}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Connection failed: {ex.Message}");
        }
    }
    else if (input.ToLower() == "disconnect")
    {
        try
        {
            await connection.StopAsync();
            Console.WriteLine($"Disconnected to the server");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Connection failed: {ex.Message}");
        }
    }
    else if (input.ToLower() == "notification")
    {
        Console.WriteLine("Please enter a notification to send, connect first !");
        try
        {
#pragma warning disable CS8600 // Converting null literal or possible null value to non-nullable type.
            string message = Console.ReadLine();
#pragma warning restore CS8600 // Converting null literal or possible null value to non-nullable type.
            await connection.InvokeAsync("Notification", connection.ConnectionId, message);
            Console.WriteLine($"Message send");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Message failed: {ex.Message}");
        }
       
    }
    else if (input.ToLower() == "help")
    {
        DisplayHelp();
    }
    else if (input.ToLower() == "exit")
    {
        Console.WriteLine("Exiting the application...");
        break;
    }
    else
    {
        Console.WriteLine($"Unknown command: {input}");
    }
}

static void DisplayHelp()
{
    Console.WriteLine("\nAvailable commands:");
    Console.WriteLine("help - Displays the available commands.");
    Console.WriteLine("connect - Disconnect connection.");
    Console.WriteLine("disconnect - Disconnect connection.");
    Console.WriteLine("notification - Send notification.");
    Console.WriteLine("exit - Exits the application.");
}
