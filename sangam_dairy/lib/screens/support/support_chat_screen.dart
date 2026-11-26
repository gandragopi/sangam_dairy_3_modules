import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/support_api_service.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color pageBackground = Color(0xFFF6F9F6);

  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  List<Map<String, dynamic>> _messages = [];

  Timer? _refreshTimer;

  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _loadMessages();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        _loadMessages(silent: true);
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({
    bool silent = false,
  }) async {
    try {
      final messages =
      await SupportApiService.getMessages();

      if (!mounted) {
        return;
      }

      setState(() {
        _messages = messages;
        _loading = false;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) {
        return;
      }

      if (!silent) {
        setState(() {
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to connect to support chat.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final String message =
    _messageController.text.trim();

    if (message.isEmpty || _sending) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await SupportApiService.sendMessage(message);

      _messageController.clear();

      await _loadMessages();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Message could not be sent.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chat with Us',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )
                : _messages.isEmpty
                ? const Center(
              child: Text(
                'Start a conversation with Sangam Dairy support.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message =
                _messages[index];

                final bool customer =
                    message['sender'] ==
                        'CUSTOMER';

                return Align(
                  alignment: customer
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints:
                    const BoxConstraints(
                      maxWidth: 300,
                    ),
                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: customer
                          ? primaryGreen
                          : Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),
                      border: Border.all(
                        color: customer
                            ? primaryGreen
                            : const Color(
                          0xFFE1E8E2,
                        ),
                      ),
                    ),
                    child: Text(
                      message['message']
                          ?.toString() ??
                          '',
                      style: TextStyle(
                        color: customer
                            ? Colors.white
                            : darkGreen,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                10,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE1E8E2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction:
                      TextInputAction.send,
                      onSubmitted: (_) =>
                          _sendMessage(),
                      decoration: InputDecoration(
                        hintText:
                        'Type your message...',
                        filled: true,
                        fillColor:
                        const Color(0xFFF6F9F6),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed:
                      _sending ? null : _sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      icon: _sending
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.send_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
