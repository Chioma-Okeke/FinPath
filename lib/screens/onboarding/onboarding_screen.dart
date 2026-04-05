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

  void _nextPage() {
    if (_currentPage < _lastPageIndex) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _submitOnboarding();
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
    super.dispose();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0D3B66)),
                onPressed: _prevPage,
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          _t('Getting to know you', 'Conociéndote'),
          style: const TextStyle(color: Color(0xFF0D3B66)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF0D3B66),
          ),
        ),
      ),
      body: (_isLoading || _isOptionsLoading || _options == null)
          ? const Center(child: CircularProgressIndicator())
          : PopScope(
              canPop: _currentPage == 0,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) _prevPage();
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

  // ─── Question Card Shell ───────────────────────────────────────────────────

  Widget _buildQuestionCard({
    required String question,
    required Widget child,
    bool canProceed = true,
    String? subtitle,
  }) {
    final isLastPage = _currentPage == _lastPageIndex;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B66),
              height: 1.4,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 24),
          Expanded(child: child),
          ElevatedButton(
            onPressed: canProceed ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B66),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isLastPage
                  ? _t('See my financial snapshot', 'Ver mi perfil financiero')
                  : _t('Continue', 'Continuar'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t(
              '${_currentPage + 1} of $_totalPages',
              '${_currentPage + 1} de $_totalPages',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Q1: Life Situation ────────────────────────────────────────────────────

  Widget _buildLifeSituationPage() {
    final options = _options!.lifeSituations;

    return _buildQuestionCard(
      question: _t(
        'What best describes your life situation?',
        '¿Qué describe mejor tu situación actual?',
      ),
      subtitle: _t(
        'Select all that apply',
        'Selecciona todo lo que corresponda',
      ),
      canProceed: _lifeSituations.isNotEmpty,
      child: ListView(
        children: [
          ...options.map((opt) {
            final key = opt.value;
            final isSelected = _lifeSituations.contains(key);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CheckTile(
                  label: opt.display(widget.language),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected) {
                        _lifeSituations.add(key);
                      } else {
                        _lifeSituations.remove(key);

                        if ((key == 'full_time_student' ||
                                key == 'student_working') &&
                            !_studentSelected) {
                          _isInternational = false;
                          _countryOfOrigin = null;
                        }

                        if (key == 'new_to_country') {
                          _countryOfOrigin = null;
                          _entryRoute = null;
                        }
                      }
                    });
                  },
                ),
                if ((key == 'full_time_student' || key == 'student_working') &&
                    isSelected)
                  _buildStudentSubOptions(),
                if (key == 'new_to_country' && isSelected)
                  _buildImmigrantSubOptions(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudentSubOptions() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D3B66).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(
              'Are you an international student?',
              '¿Eres estudiante internacional?',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D3B66),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _RadioTile(
            label: _t('International student', 'Estudiante internacional'),
            selected: _isInternational,
            onTap: () => setState(() {
              _isInternational = true;
            }),
          ),
          _RadioTile(
            label: _t(
              'Citizen / Permanent resident',
              'Ciudadano / Residente permanente',
            ),
            selected: !_isInternational,
            onTap: () => setState(() {
              _isInternational = false;
              _countryOfOrigin = null;
            }),
          ),
          if (_isInternational) ...[
            const SizedBox(height: 10),
            _buildCountryDropdown(),
          ],
        ],
      ),
    );
  }

  Widget _buildImmigrantSubOptions() {
    final entryRoutes = _options!.entryRoutes;

    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D3B66).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCountryDropdown(),
          const SizedBox(height: 14),
          Text(
            _t(
              'How did you come to this country?',
              '¿Cómo llegaste a este país?',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D3B66),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ...entryRoutes.map(
            (r) => _RadioTile(
              label: r.label(widget.language),
              selected: _entryRoute == r.value,
              onTap: () => setState(() => _entryRoute = r.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final countries = [
      'Mexico',
      'India',
      'China',
      'Philippines',
      'El Salvador',
      'Vietnam',
      'Cuba',
      'Dominican Republic',
      'Guatemala',
      'Honduras',
      'South Korea',
      'Brazil',
      'Colombia',
      'Haiti',
      'Nigeria',
      'Other',
    ];
    return DropdownButtonFormField<String>(
      value: _countryOfOrigin,
      decoration: InputDecoration(
        labelText: _t('Country of origin', 'País de origen'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items: countries
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _countryOfOrigin = v),
    );
  }

  // ─── Q2: Income Sources ────────────────────────────────────────────────────

  Widget _buildIncomeSourcesPage() {
    final options = _options!.incomeSources;

    return _buildQuestionCard(
      question: _t(
        'How do you currently get money or income?',
        '¿Cómo recibes actualmente dinero o ingresos?',
      ),
      subtitle: _t(
        'Select all that apply',
        'Selecciona todo lo que corresponda',
      ),
      canProceed: _incomeSources.isNotEmpty,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: options.map((opt) {
                final key = opt.value;

                return _CheckTile(
                  label: opt.display(widget.language),
                  value: _incomeSources.contains(key),
                  onChanged: (selected) {
                    setState(() {
                      if (key == 'no_income') {
                        if (selected) {
                          _incomeSources
                            ..clear()
                            ..add('no_income');
                        } else {
                          _incomeSources.remove('no_income');
                        }
                        return;
                      }

                      if (selected) {
                        _incomeSources.remove('no_income');
                        _incomeSources.add(key);
                      } else {
                        _incomeSources.remove(key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          if (_hasFullAndPartTime)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD54F)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF7A5C00),
                    size: 18,
                  ),
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
      ),
    );
  }

  // ─── Q3: Housing ──────────────────────────────────────────────────────────

  Widget _buildHousingPage() {
    final options = _options!.housingTypes;

    return _buildQuestionCard(
      question: _t('Where do you currently live?', '¿Dónde vives actualmente?'),
      canProceed: _housingType != null,
      child: ListView(
        children: options.map((opt) {
          return _ChoiceTile(
            label: opt.display(widget.language),
            selected: _housingType == opt.value,
            onTap: () => setState(() => _housingType = opt.value),
          );
        }).toList(),
      ),
    );
  }

  // ─── Q4: Health Insurance ─────────────────────────────────────────────────

  Widget _buildHealthInsurancePage() {
    return _buildQuestionCard(
      question: _t('Do you have health insurance?', '¿Tienes seguro médico?'),
      subtitle: _t(
        'Health coverage is the highest-cost gap for most people your age.',
        'El seguro médico es el mayor riesgo financiero para personas de tu edad.',
      ),
      canProceed: _healthAnswer != null,
      child: Column(
        children: [
          _ChoiceTile(
            label: _t(
              '✅  Yes, I have health insurance',
              '✅  Sí, tengo seguro médico',
            ),
            selected: _healthAnswer == 'yes',
            onTap: () => setState(() => _healthAnswer = 'yes'),
          ),
          _ChoiceTile(
            label: _t(
              '❌  No, I don\'t have health insurance',
              '❌  No, no tengo seguro médico',
            ),
            selected: _healthAnswer == 'no',
            onTap: () => setState(() => _healthAnswer = 'no'),
          ),
          _ChoiceTile(
            label: _t('🤔  I\'m not sure', '🤔  No estoy seguro'),
            selected: _healthAnswer == 'unsure',
            onTap: () => setState(() => _healthAnswer = 'unsure'),
          ),
        ],
      ),
    );
  }

  // ─── Q5: Auto Insurance ───────────────────────────────────────────────────

  Widget _buildAutoInsurancePage() {
    return _buildQuestionCard(
      question: _t('Do you have auto insurance?', '¿Tienes seguro de auto?'),
      subtitle: _t(
        'Auto insurance is legally required in most states.',
        'El seguro de auto es legalmente obligatorio en la mayoría de los estados.',
      ),
      canProceed: _autoAnswer != null,
      child: Column(
        children: [
          _ChoiceTile(
            label: _t(
              '✅  Yes, I have auto insurance',
              '✅  Sí, tengo seguro de auto',
            ),
            selected: _autoAnswer == 'yes',
            onTap: () => setState(() => _autoAnswer = 'yes'),
          ),
          _ChoiceTile(
            label: _t(
              '❌  No, I don\'t have auto insurance',
              '❌  No, no tengo seguro de auto',
            ),
            selected: _autoAnswer == 'no',
            onTap: () => setState(() => _autoAnswer = 'no'),
          ),
          _ChoiceTile(
            label: _t('🚫  I don\'t own a car', '🚫  No tengo auto'),
            selected: _autoAnswer == 'no_car',
            onTap: () => setState(() => _autoAnswer = 'no_car'),
          ),
        ],
      ),
    );
  }

  // ─── Q6: Emergency Fund ───────────────────────────────────────────────────

  Widget _buildEmergencyFundPage() {
    return _buildQuestionCard(
      question: _t(
        'Do you have an emergency fund?',
        '¿Tienes un fondo de emergencia?',
      ),
      subtitle: _t(
        'Even \$500–\$1,000 saved counts as a start.',
        'Incluso \$500–\$1,000 ahorrados cuentan como un inicio.',
      ),
      canProceed: _hasEmergencyFund != null,
      child: Column(
        children: [
          _ChoiceTile(
            label: _t(
              '✅  Yes, I have some savings set aside',
              '✅  Sí, tengo algo de ahorros guardados',
            ),
            selected: _hasEmergencyFund == true,
            onTap: () => setState(() => _hasEmergencyFund = true),
          ),
          _ChoiceTile(
            label: _t(
              '❌  No, I don\'t have emergency savings',
              '❌  No, no tengo ahorros de emergencia',
            ),
            selected: _hasEmergencyFund == false,
            onTap: () => setState(() => _hasEmergencyFund = false),
          ),
          _ChoiceTile(
            label: _t('🤔  I\'m working on it', '🤔  Estoy trabajando en ello'),
            selected: false,
            onTap: () => setState(() => _hasEmergencyFund = false),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Tile Widgets ──────────────────────────────────────────────────────

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D3B66) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0D3B66) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: selected ? Colors.white : const Color(0xFF333333),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.green : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              color: value ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFF333333),
                  fontWeight: value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? const Color(0xFF0D3B66) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF333333),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
