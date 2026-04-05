import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

class AIAssistantSheet extends StatefulWidget {
  const AIAssistantSheet({super.key});

  @override
  State<AIAssistantSheet> createState() => _AIAssistantSheetState();
}

class _AIAssistantSheetState extends State<AIAssistantSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  String _t(String en, String es) {
    final lang = context.read<AppState>().language;
    return lang == 'es' ? es : en;
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: question, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final answer = await ApiService.askAI(question);
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(text: answer, isUser: false));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(
          text: _t(
            'Sorry, I could not connect to the server. Please try again.',
            'Lo siento, no pude conectar con el servidor. Intenta de nuevo.',
          ),
          isUser: false,
          isError: true,
        ));
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B66),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('FinPath AI', 'FinPath IA'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0D3B66),
                      ),
                    ),
                    Text(
                      _t('Financial guidance — not professional advice',
                          'Orientación financiera — no asesoría profesional'),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[i]);
                    },
                  ),
          ),
          // Input
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: _t(
                        'Ask about your coverage, costs, options...',
                        'Pregunta sobre cobertura, costos, opciones...',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isLoading ? null : _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? Colors.grey[300]
                          : const Color(0xFF0D3B66),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isEs = context.read<AppState>().language == 'es';
    final displaySuggestions = isEs
        ? [
            '¿Mi seguro de auto cubre mi trabajo de Uber?',
            '¿Cuánto debo ahorrar para emergencias?',
            '¿Qué es un seguro de arrendatario?',
          ]
        : [
            'Does my auto insurance cover gig driving?',
            'How much emergency fund should I have?',
            "What's renter's insurance and do I need it?",
          ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          _t('Ask me anything about your finances.',
              'Pregúntame cualquier cosa sobre tus finanzas.'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ...displaySuggestions.map((s) => GestureDetector(
              onTap: () {
                _controller.text = s;
                _send();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFD0DBFF)),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    color: Color(0xFF0D3B66),
                    fontSize: 14,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMessageBubble(_Message message) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF0D3B66)
              : message.isError
                  ? Colors.red[50]
                  : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : message.isError
                    ? Colors.red[700]
                    : const Color(0xFF333333),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => _DotAnimation(delay: i * 200),
          ),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isError;

  _Message({required this.text, required this.isUser, this.isError = false});
}

class _DotAnimation extends StatefulWidget {
  final int delay;
  const _DotAnimation({required this.delay});

  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF0D3B66),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
