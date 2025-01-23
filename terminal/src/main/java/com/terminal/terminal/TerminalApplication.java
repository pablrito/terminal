package com.terminal.terminal;


import com.microsoft.signalr.HubConnection;
import com.microsoft.signalr.HubConnectionBuilder;
import com.microsoft.signalr.HubConnectionState;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.logging.LogLevel;

import java.util.Scanner;
import java.util.concurrent.ThreadLocalRandom;

@SpringBootApplication
public class TerminalApplication implements CommandLineRunner {

	@Value("${app.hubUrl}")
	private String hubUrl;

	@Value("${app.secret}")
	private String secret;

	private HubConnection hubConnection;

	public static void main(String[] args) {
		SpringApplication.run(TerminalApplication.class, args);
	}

	@Override
	public void run(String... args) {
		System.out.println("Welcome to the Terminal App!");
		System.out.println("Type 'help' to see available commands.");
		System.out.println("Type 'exit' to quit the application.");

		Scanner scanner = new Scanner(System.in);

		while (true) {
			System.out.print("\n> ");
			String input = scanner.nextLine().trim();

			switch (input.toLowerCase()) {
				case "connect":
					connect();
					break;
				case "disconnect":
					disconnect();
					break;
				case "notification":
					if (hubConnection == null || hubConnection.getConnectionState() != HubConnectionState.CONNECTED) {
						System.out.println("Please connect first!");
					} else {
						System.out.print("Enter your message: ");
						String message = scanner.nextLine();
						sendNotification(message);
					}
					break;
				case "help":
					displayHelp();
					break;
				case "exit":
					System.out.println("Exiting the application...");
					disconnect();
					return;
				default:
					System.out.println("Unknown command: " + input);
			}
		}
	}

	private void connect() {
		try {
			hubConnection = HubConnectionBuilder.create(hubUrl)
					.withHeader("X-Auth-Token", secret)
					.build();


			hubConnection.on("ReceiveMessage", (id, message) -> {
				System.out.println("Incoming message: " + id + ": " + message);

				try {
					ThreadLocalRandom random = ThreadLocalRandom.current();
					Thread.sleep(random.nextInt(1000, 10000));
					hubConnection.send("Notification", hubConnection.getConnectionId(), message + " handshake");
					Thread.sleep(random.nextInt(1000, 10000));
					hubConnection.send("Notification", hubConnection.getConnectionId(), message + " initiate");
					Thread.sleep(random.nextInt(1000, 10000));
					hubConnection.send("Notification", hubConnection.getConnectionId(), message + " done");
				} catch (InterruptedException e) {
					Thread.currentThread().interrupt();
					System.err.println("Error during message handling: " + e.getMessage());
				}
			}, String.class, String.class);


			hubConnection.start().blockingAwait();
			System.out.println("Connected to the server. Host ID: " + hubConnection.getConnectionId());
		} catch (Exception e) {
			System.err.println("Connection failed: " + e.getMessage());
		}
	}

	private void disconnect() {
		if (hubConnection != null && hubConnection.getConnectionState() == HubConnectionState.CONNECTED) {
			hubConnection.stop();
			System.out.println("Disconnected from the server.");
		} else {
			System.out.println("No active connection to disconnect.");
		}
	}

	private void sendNotification(String message) {
		try {
			hubConnection.send("Notification", hubConnection.getConnectionId(), message);
			System.out.println("Message sent: " + message);
		} catch (Exception e) {
			System.err.println("Failed to send message: " + e.getMessage());
		}
	}

	private void displayHelp() {
		System.out.println("\nAvailable commands:");
		System.out.println("help - Displays the available commands.");
		System.out.println("connect - Connect to the SignalR server.");
		System.out.println("disconnect - Disconnect from the SignalR server.");
		System.out.println("notification - Send a notification message.");
		System.out.println("exit - Exit the application.");
	}
}