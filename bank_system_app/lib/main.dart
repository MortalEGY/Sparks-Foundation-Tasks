import 'package:flutter/material.dart';

// Define the customers list here
List<Map<String, dynamic>> customers = [
  {"id": 1, "name": "Customer 1", "email": "customer1@example.com", "balance": 1000.0},
  {"id": 2, "name": "Customer 2", "email": "customer2@example.com", "balance": 1500.0},
  // Add more customer data here
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banking System'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to our Banking System',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomersListPage(),
                  ),
                );
              },
              child: Text('View All Customers'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomersListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return ListTile(
            title: Text(customer['name']),
            subtitle: Text(customer['email']),
            trailing: Text('\$${customer['balance']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerDetailPage(customer: customer),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CustomerDetailPage extends StatefulWidget {
  final Map<String, dynamic> customer;

  CustomerDetailPage({required this.customer});

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  double transferAmount = 0.0; // Initialize with zero
  Map<String, dynamic>? selectedRecipient; // Initialize as null
  List<Map<String, dynamic>> recipients = List.of(customers); // Create a copy of the customers list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${widget.customer['email']}'),
            Text('Balance: \$${widget.customer['balance']}'),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Enter Amount to Transfer'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  transferAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButton<Map<String, dynamic>>(
              hint: Text('Select Recipient'),
              value: selectedRecipient,
              onChanged: (value) {
                setState(() {
                  selectedRecipient = value;
                });
              },
              items: recipients
                  .where((recipient) => recipient != widget.customer)
                  .map<DropdownMenuItem<Map<String, dynamic>>>((recipient) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: recipient,
                  child: Text(recipient['name']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (transferAmount <= 0) {
                  // Show an error message for an invalid amount
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Amount'),
                        content: Text('Please enter a valid transfer amount.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else if (selectedRecipient == null) {
                  // Show an error message for no recipient selected
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('No Recipient Selected'),
                        content: Text('Please select a recipient to transfer money to.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Show a confirmation dialog before transferring money
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Transfer'),
                        content: Text('Transfer \$${transferAmount.toStringAsFixed(2)} to ${selectedRecipient!['name']}?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the confirmation dialog
                            },
                          ),
                          TextButton(
                            child: Text('Confirm'),
                            onPressed: () {
                              // Implement the actual money transfer logic here.
                              // Deduct the amount from the sender and add it to the receiver.
                              // Update the balances accordingly.

                              // Close the confirmation dialog
                              Navigator.of(context).pop();

                              // Update the customer's balance after the transfer
                              setState(() {
                                widget.customer['balance'] -= transferAmount;
                                selectedRecipient!['balance'] += transferAmount;
                              });

                              // Show a success message
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Transfer Successful'),
                                    content: Text('You have transferred \$${transferAmount.toStringAsFixed(2)} to ${selectedRecipient!['name']}'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Close'),
                                        onPressed: () {
                                          // Close the success dialog
                                          Navigator.of(context).pop();

                                          // Return to the main page
                                          Navigator.popUntil(context, (route) => route.isFirst);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Transfer Money'),
            ),
          ],
        ),
      ),
    );
  }
}