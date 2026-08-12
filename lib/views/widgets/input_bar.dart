import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;
  final VoidCallback? onAttachedPressed;

  const InputBar({
    super.key,
    required this.onSendMessage,
    required this.isLoading,
    this.onAttachedPressed
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController textController = TextEditingController();

  void _handleSend() {
    final text = textController.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    textController.clear();
    widget.onSendMessage(text);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFF343541),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF40414F),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Plus / Attachment Button
            GestureDetector(
              onTap: widget.isLoading ? null : widget.onAttachedPressed,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: TextField(
                controller: textController,
                enabled: !widget.isLoading,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: widget.isLoading ? "AI is thinking..." : "Message AI Assistant...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                ),
                onSubmitted: (value) {
                  _handleSend();
                },
              ),
            ),
            const SizedBox(width: 8),

            // Send Button
            GestureDetector(
              onTap: widget.isLoading ? null : _handleSend,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isLoading ? Colors.white24 : Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}