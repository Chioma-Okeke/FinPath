import 'package:finpath/models/onboarding_option.dart';
import 'package:finpath/models/onboarding_options_response.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../snapshot/snapshot_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String language;
  const OnboardingScreen({super.key, required this.language});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  OnboardingOptionsResponse? _options;
  bool _isOptionsLoading = true;

  // Q1 — Life Situation
  final Set<String> _lifeSituations = {};
  bool _isInternational = false;
  String? _countryOfOrigin;
  String? _entryRoute;
  late final TextEditingController _countrySearchController;

  // Q2 — Income Sources
  final Set<String> _incomeSources = {};

  // Q3 — Housing
  String? _housingType;

  // Q4 — Health insurance ('yes' | 'no' | 'unsure')
  String? _healthAnswer;

  // Q5 — Auto insurance ('yes' | 'no' | 'no_car')
  String? _autoAnswer;

  // Q6 — Emergency fund
  bool? _hasEmergencyFund;

  static const int _totalPages = 6;
  static const int _lastPageIndex = _totalPages - 1;

  bool get _isSpanish => widget.language == 'es';
  String _t(String en, String es) => _isSpanish ? es : en;

  bool get _studentSelected =>
      _lifeSituations.contains('full_time_student') ||
      _lifeSituations.contains('student_working');

  bool get _immigrantSelected => _lifeSituations.contains('new_to_country');

  bool get _hasFullAndPartTime =>
      _incomeSources.contains('full_time_employment') &&
      _incomeSources.contains('part_time_job');

  @override
  void initState() {
    super.initState();
    _countrySearchController = TextEditingController();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final options = await ApiService.getOnboardingOptions();
      if (!mounted) return;
      setState(() {
        _options = options;
        _isOptionsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isOptionsLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Failed to load onboarding options.',
              'No se pudieron cargar las opciones del cuestionario.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _nextPage() async {
    if (_currentPage < _lastPageIndex) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      if (!mounted) return;
      setState(() => _currentPage++);
    } else {
      await _submitOnboarding();
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        // Fallback: register anonymously if no token yet
        // final regRes = await ApiService.register('User', widget.language);
        // if (regRes['access_token'] != null) {
        //   await AuthService.saveToken(regRes['access_token']);
        //   await AuthService.saveUserId(regRes['id'] ?? 0);
        // }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'Connection error. Is the server running?',
                'Error de conexión. ¿Está el servidor activo?',
              ),
            ),
          ),
        );
      }

      await ApiService.submitOnboarding({
        'life_situations': _lifeSituations.toList(),
        'is_student': _studentSelected,
        'is_international': _isInternational,
        'country_of_origin': _countryOfOrigin,
        'entry_route': _entryRoute,
        'income_sources': _incomeSources.toList(),
        'housing_type': _housingType,
        'has_health_insurance': _healthAnswer == 'yes',
        'has_auto_insurance': _autoAnswer == 'yes',
        'has_emergency_fund': _hasEmergencyFund ?? false,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SnapshotScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Connection error. Is the server running?',
              'Error de conexión. ¿Está el servidor activo?',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countrySearchController.dispose();
    super.dispose();
  }

  Future<void> _prevPage() async {
    if (_currentPage > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      if (!mounted) return;
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLifeSituationStep = _currentPage == 0;

    final showStepInAppBar = _currentPage == 3 || _currentPage == 5;
    final appBar = AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF333333)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      automaticallyImplyLeading: false,
      centerTitle: !showStepInAppBar,
      title: Text(
        _t('Financial Journey', 'Camino Financiero'),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      actions: showStepInAppBar
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    _t(
                      'STEP ${_currentPage + 1} OF 6',
                      'PASO ${_currentPage + 1} DE 6',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A7A6E),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ]
          : null,
    );

    return Scaffold(
      backgroundColor: isLifeSituationStep
          ? const Color(0xFFF7F4EC)
          : const Color(0xFFF5F7FA),
      appBar: appBar,
      body: (_isLoading || _isOptionsLoading || _options == null)
          ? const Center(child: CircularProgressIndicator())
          : PopScope(
              canPop: _currentPage == 0,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) {
                  _prevPage();
                }
              },
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLifeSituationPage(), // Q1
                  _buildIncomeSourcesPage(), // Q2
                  _buildHousingPage(), // Q3
                  _buildHealthInsurancePage(), // Q4
                  _buildAutoInsurancePage(), // Q5
                  _buildEmergencyFundPage(), // Q6
                ],
              ),
            ),
    );
  }

  // ─── Q1: Life Situation ────────────────────────────────────────────────────

  IconData _lifeSituationIcon(String key) {
    if (key.contains('student')) return Icons.school_rounded;
    if (key.contains('working_professional') || key == 'employed') return Icons.work_rounded;
    if (key.contains('graduated') || key.contains('graduate')) return Icons.emoji_events_rounded;
    if (key.contains('new_to_country') || key.contains('immigrant')) return Icons.flight_land_rounded;
    if (key.contains('self_employ') || key.contains('gig') || key.contains('freelance')) return Icons.handyman_rounded;
    if (key.contains('family') || key.contains('staying')) return Icons.home_rounded;
    return Icons.person_rounded;
  }

  Widget _buildLifeSituationPage() {
    final options = _options!.lifeSituations;

    return Column(
      children: [
        // Step indicator
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _t('STEP 1 OF 6', 'PASO 1 DE 6'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A7A6E),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _t('Progress: 16%', 'Progreso: 16%'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1 / _totalPages,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A7A6E)),
                minHeight: 4,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(
                    'What does your current life situation look like?',
                    '¿Cómo es tu situación de vida actual?',
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _t(
                    'This helps us tailor your financial sanctuary to the specific challenges and opportunities of your journey. You can select multiple options.',
                    'Esto nos ayuda a personalizar tu santuario financiero. Puedes seleccionar múltiples opciones.',
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 24),

                // Option cards
                ...options.map((opt) {
                  final key = opt.value;
                  final isSelected = _lifeSituations.contains(key);
                  final isStudent = key == 'full_time_student' || key == 'student_working';
                  final isImmigrant = key == 'new_to_country';

                  return _buildLifeSituationCard(
                    key: key,
                    label: opt.label(widget.language),
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _lifeSituations.remove(key);
                          if (isStudent && !_studentSelected) {
                            _isInternational = false;
                            _countryOfOrigin = null;
                            _countrySearchController.clear();
                          }
                          if (isImmigrant) {
                            _countryOfOrigin = null;
                            _entryRoute = null;
                            _countrySearchController.clear();
                          }
                        } else {
                          _lifeSituations.add(key);
                        }
                      });
                    },
                    subOptions: isSelected
                        ? isStudent
                            ? _buildStudentSubOptions()
                            : isImmigrant
                                ? _buildImmigrantSubOptions()
                                : null
                        : null,
                  );
                }),

                const SizedBox(height: 16),

                // Private & Protected card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_outline, color: Color(0xFF1A7A6E), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('Private & Protected', 'Privado y Protegido'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _t(
                                'We use this information only to provide specialized advice (like international student tax tips or gig economy budgeting). Your data is encrypted and never shared.',
                                'Usamos esta información solo para brindarte consejos especializados. Tus datos están encriptados y nunca se comparten.',
                              ),
                              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Bottom navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                label: Text(
                  _t('BACK', 'ATRÁS'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _lifeSituations.isNotEmpty ? _nextPage : null,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  _t('CONTINUE', 'CONTINUAR'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A6E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLifeSituationCard({
    required String key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? subOptions,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A7A6E) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD6EDE9) : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _lifeSituationIcon(key),
                      color: isSelected ? const Color(0xFF1A7A6E) : Colors.grey[600],
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? const Color(0xFF1A7A6E) : Colors.grey[400],
                    size: 24,
                  ),
                ],
              ),
            ),
            if (subOptions != null) ...[
              Divider(height: 1, color: Colors.grey[200]),
              subOptions,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSubOptions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('STATUS DETAILS', 'DETALLES DE ESTADO'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(
                label: _t('International student', 'Estudiante internacional'),
                selected: _isInternational,
                onTap: () => setState(() => _isInternational = true),
              ),
              _buildStatusChip(
                label: _t('Citizen / permanent resident', 'Ciudadano / residente permanente'),
                selected: !_isInternational,
                onTap: () => setState(() {
                  _isInternational = false;
                  _countryOfOrigin = null;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A7A6E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1A7A6E) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildImmigrantSubOptions() {
    final entryRoutes = _options!.entryRoutes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('COUNTRY OF ORIGIN', 'PAÍS DE ORIGEN'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _countrySearchController,
            decoration: InputDecoration(
              hintText: _t('Search country...', 'Buscar país...'),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              suffixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1A7A6E), width: 1.5),
              ),
            ),
            onChanged: (v) => setState(() => _countryOfOrigin = v.trim().isEmpty ? null : v.trim()),
          ),
          const SizedBox(height: 14),
          Text(
            _t('ENTRY ROUTE', 'RUTA DE ENTRADA'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _entryRoute,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1A7A6E), width: 1.5),
              ),
            ),
            hint: Text(
              _t('Select entry route', 'Seleccionar ruta de entrada'),
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            items: entryRoutes
                .map((r) => DropdownMenuItem(value: r.value, child: Text(r.label(widget.language))))
                .toList(),
            onChanged: (v) => setState(() => _entryRoute = v),
          ),
        ],
      ),
    );
  }

  // ─── Q2: Income Sources ────────────────────────────────────────────────────

  IconData _incomeIcon(String key) {
    if (key.contains('full_time')) return Icons.work_rounded;
    if (key.contains('part_time')) return Icons.work_outline_rounded;
    if (key.contains('freelance') || key.contains('gig')) return Icons.devices_rounded;
    if (key.contains('government') || key.contains('welfare') || key.contains('benefit')) return Icons.account_balance_rounded;
    if (key.contains('unemployment')) return Icons.support_agent_rounded;
    if (key.contains('family') || key.contains('parents') || key.contains('allowance')) return Icons.people_rounded;
    if (key.contains('scholarship') || key.contains('stipend') || key.contains('student_aid')) return Icons.school_rounded;
    if (key.contains('invest') || key.contains('dividend')) return Icons.trending_up_rounded;
    if (key.contains('rental') || key.contains('property')) return Icons.home_rounded;
    if (key.contains('social_security') || key.contains('disability')) return Icons.health_and_safety_rounded;
    if (key.contains('no_income') || key.contains('none')) return Icons.block_rounded;
    return Icons.attach_money_rounded;
  }

  Widget _buildIncomeCard({
    required String key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A7A6E) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(_incomeIcon(key), color: Colors.grey[600], size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF222222),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF1A7A6E) : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSourcesPage() {
    final options = _options!.incomeSources;

    return Column(
      children: [
        // Step indicator
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _t('STEP 2 OF 6', 'PASO 2 DE 6'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A7A6E),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '— ${_t('Income Profile', 'Perfil de Ingresos')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 2 / _totalPages,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      _t('Where does your money come from?', '¿De dónde viene tu dinero?'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _t(
                        'Select all sources that apply to your current financial situation. This helps us tailor your sanctuary of stability.',
                        'Selecciona todas las fuentes que apliquen a tu situación financiera actual. Esto nos ayuda a personalizar tu santuario de estabilidad.',
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 20),

                    // Income source cards
                    ...options.map((opt) {
                      final key = opt.value;
                      final isSelected = _incomeSources.contains(key);
                      return _buildIncomeCard(
                        key: key,
                        label: opt.display(widget.language),
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (key == 'no_income') {
                              if (!isSelected) {
                                _incomeSources
                                  ..clear()
                                  ..add('no_income');
                              } else {
                                _incomeSources.remove('no_income');
                              }
                              return;
                            }
                            if (!isSelected) {
                              _incomeSources.remove('no_income');
                              _incomeSources.add(key);
                            } else {
                              _incomeSources.remove(key);
                            }
                          });
                        },
                      );
                    }),

                    // "Why we ask" info card
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF0),
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(color: Color(0xFFE8B84B), width: 4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Color(0xFFE8B84B), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5),
                                children: [
                                  TextSpan(
                                    text: _t('Why we ask: ', '¿Por qué preguntamos? '),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                                  ),
                                  TextSpan(
                                    text: _t(
                                      'Your income sources help us identify specific tax benefits or savings programs that might apply to your unique professional situation.',
                                      'Tus fuentes de ingresos nos ayudan a identificar beneficios fiscales o programas de ahorro específicos para tu situación profesional.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_hasFullAndPartTime) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD54F)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF7A5C00), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _t(
                                  'You selected both full-time and part-time — we\'ll make sure your coverage reflects both.',
                                  'Seleccionaste tiempo completo y medio tiempo — revisaremos tu cobertura para ambos.',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF7A5C00),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                label: Text(
                  _t('BACK', 'ATRÁS'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _incomeSources.isNotEmpty ? _nextPage : null,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  _t('CONTINUE', 'CONTINUAR'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A6E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Q3: Housing ──────────────────────────────────────────────────────────

  (IconData, String, String) _housingInfo(String key) {
    // Returns (icon, subtitle_en, subtitle_es)
    if (key.contains('rent')) {
      return (Icons.apartment_rounded, 'Apartment, flat, or rented house.', 'Apartamento, piso o casa alquilada.');
    }
    if (key.contains('own') || key.contains('homeown')) {
      return (Icons.home_rounded, 'I own my current residence.', 'Soy propietario de mi residencia actual.');
    }
    if (key.contains('famil') || key.contains('parent') || key.contains('shared')) {
      return (Icons.people_rounded, "Shared household or parent's home.", 'Hogar compartido o casa de los padres.');
    }
    if (key.contains('dorm') || key.contains('student')) {
      return (Icons.school_rounded, 'Student housing or dormitory.', 'Residencia estudiantil o dormitorio.');
    }
    if (key.contains('shelter') || key.contains('homeless')) {
      return (Icons.night_shelter_rounded, 'Temporary shelter or transitional housing.', 'Albergue temporal o vivienda de transición.');
    }
    return (Icons.other_houses_rounded, 'Temporary housing or unique situations.', 'Vivienda temporal o situaciones únicas.');
  }

  Widget _buildHousingCard({
    required String key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final (icon, subtitleEn, subtitleEs) = _housingInfo(key);
    final subtitle = _isSpanish ? subtitleEs : subtitleEn;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A7A6E) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD6EDE9) : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF1A7A6E) : Colors.grey[500],
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1A7A6E), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHousingPage() {
    final options = _options!.housingTypes;

    return Column(
      children: [
        // Step indicator
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _t('Step 3 of 6', 'Paso 3 de 6'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A7A6E),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _t('Housing', 'Vivienda'),
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 3 / _totalPages,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      _t('Where do you currently live?', '¿Dónde vives actualmente?'),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _t(
                        "This helps us determine if you need renter's or homeowner's coverage.",
                        'Esto nos ayuda a determinar si necesitas cobertura de inquilino o propietario.',
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Housing option cards
                    ...options.map((opt) => _buildHousingCard(
                      key: opt.value,
                      label: opt.display(widget.language),
                      isSelected: _housingType == opt.value,
                      onTap: () => setState(() => _housingType = opt.value),
                    )),

                    const SizedBox(height: 8),

                    // Full amber "Why we ask" card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5A623).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('Why we ask', '¿Por qué preguntamos?'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _t(
                                    'Your living situation significantly impacts your monthly obligations. We use this to calculate a more accurate wellness score tailored to your lifestyle.',
                                    'Tu situación de vivienda impacta significativamente tus obligaciones mensuales. Usamos esto para calcular un puntaje de bienestar más preciso adaptado a tu estilo de vida.',
                                  ),
                                  style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                label: Text(
                  _t('BACK', 'ATRÁS'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _housingType != null ? _nextPage : null,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  _t('CONTINUE', 'CONTINUAR'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A6E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Q4: Health Insurance ─────────────────────────────────────────────────

  Widget _buildHealthInsurancePage() {
    return Column(
      children: [
        // Thick progress bar
        LinearProgressIndicator(
          value: 4 / _totalPages,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A7A6E)),
          minHeight: 6,
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDF2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _t('Health & Wellness', 'Salud y Bienestar'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3A4A5C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  _t('Do you have health insurance?', '¿Tienes seguro médico?'),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                // Subtitle
                Text(
                  _t(
                    'A health gap is often the highest-cost risk. Protecting your physical health is the foundation of long-term wealth preservation.',
                    'Una brecha de salud suele ser el riesgo de mayor costo. Proteger tu salud física es la base de la preservación de la riqueza a largo plazo.',
                  ),
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.6),
                ),
                const SizedBox(height: 28),

                // Option cards
                _buildHealthOptionCard(
                  icon: Icons.verified_user_rounded,
                  iconColor: const Color(0xFF1A7A6E),
                  iconBgColor: const Color(0xFFD6EDE9),
                  label: _t("Yes, I'm covered", 'Sí, estoy cubierto'),
                  description: _t(
                    'I have active insurance through my employer, private plan, or state program.',
                    'Tengo seguro activo a través de mi empleador, un plan privado o un programa estatal.',
                  ),
                  isSelected: _healthAnswer == 'yes',
                  onTap: () => setState(() => _healthAnswer = 'yes'),
                ),
                const SizedBox(height: 16),
                _buildHealthOptionCard(
                  icon: Icons.more_horiz_rounded,
                  iconColor: const Color(0xFF555555),
                  iconBgColor: const Color(0xFFE0E0E0),
                  label: _t('Not currently', 'Actualmente no'),
                  description: _t(
                    'I am currently looking for options or do not have active coverage at this time.',
                    'Actualmente estoy buscando opciones o no tengo cobertura activa en este momento.',
                  ),
                  isSelected: _healthAnswer == 'no',
                  onTap: () => setState(() => _healthAnswer = 'no'),
                ),
                const SizedBox(height: 28),

                // Why we ask card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, color: Color(0xFFE8A020), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('Why we ask', '¿Por qué preguntamos?'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _t(
                                'Medical debt is the #1 cause of bankruptcy. We factor this into your "Safety Net" calculations to ensure you\'re truly prepared for life\'s surprises.',
                                'La deuda médica es la causa #1 de bancarrota. Lo incluimos en el cálculo de tu "Red de Seguridad" para asegurarte de estar verdaderamente preparado.',
                              ),
                              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Bottom navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                label: Text(
                  _t('BACK', 'ATRÁS'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _healthAnswer != null ? _nextPage : null,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  _t('CONTINUE', 'CONTINUAR'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A6E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthOptionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A7A6E) : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Q5: Auto Insurance ───────────────────────────────────────────────────

  Widget _buildAutoInsurancePage() {
    return Column(
      children: [
        // Progress section
        Container(
          color: const Color(0xFFF7F6F2),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('ONBOARDING PROGRESS', 'PROGRESO DE INCORPORACIÓN'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _t('Step 5 of 6', 'Paso 5 de 6'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A7A6E),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '83%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 5 / _totalPages,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A7A6E)),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                // Main content card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Car icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB2E8E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: Color(0xFF1A7A6E),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        _t('Do you have auto insurance?', '¿Tienes seguro de auto?'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        _t(
                          "It's often legally required and a critical gap for gig workers. We'll help you find the best rates for your situation.",
                          'Suele ser obligatorio por ley y una brecha crítica para trabajadores independientes. Te ayudaremos a encontrar las mejores tarifas.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Yes option card
                      _buildAutoOptionCard(
                        icon: Icons.check_circle,
                        iconColor: Colors.white,
                        iconBgColor: const Color(0xFF2A2A2A),
                        label: _t('Yes', 'Sí'),
                        sublabel: _t("I'm currently covered", 'Estoy cubierto actualmente'),
                        isSelected: _autoAnswer == 'yes',
                        onTap: () => setState(() => _autoAnswer = 'yes'),
                      ),
                      const SizedBox(height: 12),

                      // No option card
                      _buildAutoOptionCard(
                        icon: Icons.cancel,
                        iconColor: Colors.white,
                        iconBgColor: const Color(0xFF2A2A2A),
                        label: _t('No', 'No'),
                        sublabel: _t('I need coverage', 'Necesito cobertura'),
                        isSelected: _autoAnswer == 'no',
                        onTap: () => setState(() => _autoAnswer = 'no'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Secure verification image card
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2E5E52), Color(0xFF1A3A30)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Road texture overlay
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(
                          size: const Size(double.infinity, 160),
                          painter: _RoadPainter(),
                        ),
                      ),
                      // Badge
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFFE8A020),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _t('SECURE VERIFICATION', 'VERIFICACIÓN SEGURA'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Bottom navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                label: Text(
                  _t('BACK', 'ATRÁS'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _autoAnswer != null ? _nextPage : null,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  _t('CONTINUE', 'CONTINUAR'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A6E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutoOptionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD6EDE9) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: const Color(0xFF1A7A6E), width: 2)
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A7A6E) : iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Q6: Emergency Fund ───────────────────────────────────────────────────

  Widget _buildEmergencyFundPage() {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: title + 100% + progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _t(
                            'Do you have an emergency fund?',
                            '¿Tienes un fondo de emergencia?',
                          ),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A5C52),
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB2E8D8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A5C52),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Full-width progress bar (100%)
                LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A7A6E)),
                  minHeight: 5,
                ),
                const SizedBox(height: 28),

                // Option cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildEmergencyOptionCard(
                        label: _t("Yes, I'm covered", 'Sí, estoy cubierto'),
                        description: _t(
                          'I have 3-6 months of expenses saved away.',
                          'Tengo entre 3 y 6 meses de gastos ahorrados.',
                        ),
                        isSelected: _hasEmergencyFund == true,
                        onTap: () => setState(() => _hasEmergencyFund = true),
                      ),
                      const SizedBox(height: 12),
                      _buildEmergencyOptionCard(
                        label: _t('Not yet', 'Aún no'),
                        description: _t(
                          "I'm still working on building that safety net.",
                          'Aún estoy trabajando en construir esa red de seguridad.',
                        ),
                        isSelected: _hasEmergencyFund == false,
                        onTap: () => setState(() => _hasEmergencyFund = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Why this matters card (dark teal)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A5C52),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A7A6E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _t('Why this matters', 'Por qué importa'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xCCFFFFFF),
                              height: 1.6,
                            ),
                            children: [
                              TextSpan(
                                text: _t(
                                  'Financial peace of mind starts with a safety net. While 3-6 months is the ideal, experts recommend a ',
                                  'La tranquilidad financiera comienza con una red de seguridad. Aunque 3-6 meses es lo ideal, los expertos recomiendan ',
                                ),
                              ),
                              TextSpan(
                                text: _t('\$1,000 starter goal', 'una meta inicial de \$1,000'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: _t(
                                  '. This prevents small surprises like car repairs from turning into high-interest debt.',
                                  '. Esto evita que pequeñas sorpresas como reparaciones de auto se conviertan en deuda con altos intereses.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Consistent Growth section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5D98A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.savings_rounded,
                          color: Color(0xFF7A5500),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Consistent Growth', 'Crecimiento Constante'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            _t('Small deposits add up quickly.', 'Los pequeños depósitos suman rápido.'),
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Decorative image card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 170,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(painter: _SavingsJarPainter()),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Text(
                              _t('SAFETY FIRST', 'SEGURIDAD PRIMERO'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Bottom navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                label: Text(
                  _t('BACK', 'ATRÁS'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _hasEmergencyFund != null ? _nextPage : null,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  _t('CONTINUE', 'CONTINUAR'),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A6E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyOptionCard({
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A7A6E) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1A7A6E) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF1A7A6E) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Road Painter (step 5 decorative card) ────────────────────────────────────

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()..color = const Color(0xFF5B8FA8);
    final groundPaint = Paint()..color = const Color(0xFF8B7355);
    final roadPaint = Paint()..color = const Color(0xFF4A4A4A);
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Sky
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.55), skyPaint);
    // Ground
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45), groundPaint);

    // Road (trapezoid perspective)
    final roadPath = Path()
      ..moveTo(size.width * 0.3, size.height)
      ..lineTo(size.width * 0.7, size.height)
      ..lineTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.5)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    // Center dashes
    for (int i = 0; i < 4; i++) {
      final t = 0.55 + i * 0.12;
      final w = size.width * (0.01 + i * 0.008);
      canvas.drawLine(
        Offset(size.width / 2, size.height * t),
        Offset(size.width / 2, size.height * (t + 0.06)),
        linePaint..strokeWidth = w * 2,
      );
    }
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) => false;
}

// ─── Savings Jar Painter (step 6 decorative card) ─────────────────────────────

class _SavingsJarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient (warm green bokeh)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E6B3E), Color(0xFF1A3D28)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Bokeh circles (light flares)
    final bokhPaint = Paint()..color = const Color(0x33FFD700);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.3), 36, bokhPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.15), 22, bokhPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7), 18,
        bokhPaint..color = const Color(0x22FFFFFF));

    // Jar body
    final jarPaint = Paint()..color = const Color(0xBBD4E8CC);
    final jarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.28, size.width * 0.3, size.height * 0.58),
      const Radius.circular(8),
    );
    canvas.drawRRect(jarRect, jarPaint);

    // Jar lid
    final lidPaint = Paint()..color = const Color(0xCCA0B8A0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.33, size.height * 0.22, size.width * 0.34, size.height * 0.09),
        const Radius.circular(4),
      ),
      lidPaint,
    );

    // Coins inside jar (stacked circles)
    final coinPaint = Paint()..color = const Color(0xCCE8A020);
    for (int i = 0; i < 4; i++) {
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.37,
          size.height * (0.67 - i * 0.07),
          size.width * 0.26,
          size.height * 0.06,
        ),
        coinPaint,
      );
    }

    // Plant stem
    final stemPaint = Paint()
      ..color = const Color(0xFF3A8A3A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final stemPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.28)
      ..cubicTo(
        size.width * 0.5, size.height * 0.1,
        size.width * 0.5, size.height * 0.05,
        size.width * 0.5, size.height * 0.02,
      );
    canvas.drawPath(stemPath, stemPaint);

    // Left leaf
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    final leftLeaf = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.28, size.height * 0.08,
        size.width * 0.3, size.height * 0.2,
      )
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.18, size.width * 0.5, size.height * 0.15);
    canvas.drawPath(leftLeaf, leafPaint);

    // Right leaf
    final rightLeaf = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.72, size.height * 0.03,
        size.width * 0.7, size.height * 0.18,
      )
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.14, size.width * 0.5, size.height * 0.1);
    canvas.drawPath(rightLeaf, leafPaint);
  }

  @override
  bool shouldRepaint(_SavingsJarPainter oldDelegate) => false;
}


