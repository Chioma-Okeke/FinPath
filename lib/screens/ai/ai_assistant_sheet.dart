import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';

class AIAssistantSheet extends StatefulWidget {
  const AIAssistantSheet({super.key});

  static void open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AIAssistantSheet()),
    );
  }

  @override
  State<AIAssistantSheet> createState() => _AIAssistantSheetState();
}

class _AIAssistantSheetState extends State<AIAssistantSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  static const _teal = Color(0xFF1A7A6E);
  static const _bg = Color(0xFFF2EDE4);

  @override
  void initState() {
    super.initState();
    _addWelcome();
  }

  void _addWelcome() {
    final isEs = context.read<AppState>().language == 'es';
    final name = context.read<AppState>().userName;
    final greeting = name.isNotEmpty
        ? (isEs
              ? 'Hola $name, soy tu asistente financiero FinPath. ¿En qué puedo ayudarte hoy?'
              : 'Hi $name, I\'m your FinPath financial assistant. What can I help you with today?')
        : (isEs
              ? '¡Hola! Soy tu asistente financiero FinPath. ¿En qué puedo ayudarte hoy?'
              : 'Hi! I\'m FinPath financial assistant. What can I help you with today?');

    _messages.add(
      _Message(
        text: greeting,
        isUser: false,
        suggestions: isEs
            ? [
                '¿Mi seguro cubre gig driving?',
                '¿Cuánto debo ahorrar?',
                '¿Qué es seguro de arrendatario?',
              ]
            : [
                'Does my insurance cover gig driving?',
                'How much should I save?',
                "What's renter's insurance?",
              ],
      ),
    );
  }

  String _t(String en, String es) {
    final lang = context.read<AppState>().language;
    return lang == 'es' ? es : en;
  }

  Future<void> _send([String? preset]) async {
    final question = (preset ?? _controller.text).trim();
    if (question.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_Message(text: question, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final answer = await ApiService.askAI(question);
      if (!mounted) return;
      final isEs = context.read<AppState>().language == 'es';
      setState(() {
        _messages.add(
          _Message(
            text: answer,
            isUser: false,
            suggestions: isEs
                ? [
                    'Cuéntame más',
                    '¿Cómo me afecta?',
                    '¿Qué hago a continuación?',
                  ]
                : [
                    'Tell me more',
                    'How does this affect me?',
                    'What should I do next?',
                  ],
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _Message(
            text: _t(
              'Sorry, I could not connect to the server. Please try again.',
              'Lo siento, no pude conectar con el servidor. Intenta de nuevo.',
            ),
            isUser: false,
            isError: true,
          ),
        );
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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final appState = context.watch<AppState>();
    final name = appState.userName;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FinPath',
          style: TextStyle(
            color: _teal,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: 1 + _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                // Date separator at top
                if (i == 0) return _buildDateSeparator();

                final msgIndex = i - 1;

                if (_isLoading && msgIndex == _messages.length) {
                  return _buildTypingIndicator();
                }

                final msg = _messages[msgIndex];
                return _buildMessageBlock(msg, msgIndex);
              },
            ),
          ),

          // Footer disclaimer
          Padding(
            padding: const EdgeInsets.only(bottom: 6, top: 2),
            child: Text(
              _t(
                'FinPath provides educational info, not legal or financial advice.',
                'FinPath ofrece información educativa, no asesoría legal o financiera.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),

          // Input bar
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: EdgeInsets.only(bottom: bottomInset),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4DC),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                const SizedBox(width: 4),
                // + button
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: _t(
                        'Ask about insurance, savings, or...',
                        'Pregunta sobre seguros, ahorros...',
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Send button
                GestureDetector(
                  onTap: _isLoading ? null : () => _send(),
                  child: Container(
                    width: 42,
                    height: 42,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.grey[400] : _teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDDDAD4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _t('TODAY', 'HOY'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBlock(_Message msg, int index) {
    if (msg.isUser) {
      return _buildUserBubble(msg);
    }
    return _buildAiBubble(msg, index);
  }

  Widget _buildUserBubble(_Message msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: _teal,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          msg.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAiBubble(_Message msg, int index) {
    final timeStr = _formatTime(msg.timestamp);
    // Show pro-tip after second AI message onwards (index 0 is welcome, so index >= 2 means real responses)
    final showProTip =
        !msg.isError && index >= 2 && index == _messages.length - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sparkle avatar
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 10, top: 2),
                decoration: BoxDecoration(
                  color: _teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              // Bubble
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isError
                        ? Colors.red[50]
                        : const Color(0xFFECEAE5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: MarkdownBody(
                    data: msg.text,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: msg.isError
                            ? Colors.red[700]
                            : const Color(0xFF1A1A1A),
                        fontSize: 15,
                        height: 1.6,
                      ),
                      h1: const TextStyle(
                        color: _teal,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        color: _teal,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      h3: const TextStyle(
                        color: _teal,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                      listBullet: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(left: 50, top: 6),
            child: Text(
              '${_t('Assistant', 'Asistente')} • $timeStr',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
          // Quick reply chips
          if (msg.suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: msg.suggestions
                    .map((s) => _QuickChip(label: s, onTap: () => _send(s)))
                    .toList(),
              ),
            ),
          ],

          // Pro-tip card
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: BoxDecoration(
              color: _teal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFECEAE5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _DotAnimation(delay: i * 200)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }
}

// ── Quick reply chip ──────────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1A7A6E), width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A7A6E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Message model ─────────────────────────────────────────────────────────────

class _Message {
  final String text;
  final bool isUser;
  final bool isError;
  final List<String> suggestions;
  final DateTime timestamp;

  _Message({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.suggestions = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ── Dot animation ─────────────────────────────────────────────────────────────

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
          color: Color(0xFF1A7A6E),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
