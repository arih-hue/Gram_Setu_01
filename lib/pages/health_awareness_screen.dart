import 'package:flutter/material.dart';


import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';

class HealthAwarenessScreen extends StatefulWidget {
  const HealthAwarenessScreen({super.key});

  @override
  State<HealthAwarenessScreen> createState() => _HealthAwarenessScreenState();
}

class _HealthAwarenessScreenState extends State<HealthAwarenessScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasSearched = false;
  Map<String, dynamic>? _result;

  // Local knowledge base for common diseases
  final Map<String, Map<String, dynamic>> _healthData = {
    'malaria': {
      'disease': 'Malaria',
      'description': 'Malaria is a mosquito-borne infectious disease caused by Plasmodium parasites.',
      'symptoms': ['High fever with chills', 'Sweating', 'Headache', 'Nausea and vomiting', 'Body aches', 'Fatigue'],
      'prevention': [
        'Use mosquito nets while sleeping',
        'Apply mosquito repellent on exposed skin',
        'Wear long-sleeved clothing in the evening',
        'Remove stagnant water around homes',
        'Use mosquito coils or sprays indoors',
        'Keep doors and windows closed after dark',
        'Take antimalarial medication if prescribed',
      ],
      'urgency': 'High — seek medical help within 24 hours of fever onset',
    },
    'dengue': {
      'disease': 'Dengue Fever',
      'description': 'Dengue is a viral infection spread by Aedes mosquitoes, common during monsoon.',
      'symptoms': ['High fever (40°C / 104°F)', 'Severe headache', 'Pain behind the eyes', 'Joint and muscle pain', 'Skin rash', 'Mild bleeding from nose/gums'],
      'prevention': [
        'Eliminate standing water where mosquitoes breed',
        'Use mosquito repellent containing DEET',
        'Wear protective clothing',
        'Install window screens',
        'Use bed nets during daytime rest',
        'Keep water containers covered',
        'Community clean-up drives regularly',
      ],
      'urgency': 'High — monitor platelet count, seek hospital care if bleeding occurs',
    },
    'typhoid': {
      'disease': 'Typhoid Fever',
      'description': 'Typhoid is a bacterial infection caused by Salmonella typhi, spread through contaminated food and water.',
      'symptoms': ['Sustained high fever', 'Weakness', 'Stomach pain', 'Headache', 'Loss of appetite', 'Constipation or diarrhea'],
      'prevention': [
        'Drink only boiled or filtered water',
        'Wash hands thoroughly before eating',
        'Avoid street food and raw vegetables',
        'Get typhoid vaccination',
        'Ensure proper sanitation and sewage disposal',
        'Keep food covered and refrigerated',
        'Wash fruits and vegetables with clean water',
      ],
      'urgency': 'Medium — consult a doctor if fever persists beyond 3 days',
    },
    'diarrhea': {
      'disease': 'Diarrhea',
      'description': 'Diarrhea is frequent loose or watery stools, often caused by infection or contaminated food/water.',
      'symptoms': ['Watery stools 3+ times a day', 'Stomach cramps', 'Nausea', 'Dehydration', 'Fever', 'Blood in stool (severe)'],
      'prevention': [
        'Drink clean boiled or filtered water',
        'Wash hands with soap before eating and after toilet',
        'Use ORS (Oral Rehydration Solution) at first sign',
        'Avoid raw or undercooked food',
        'Keep food covered',
        'Breastfeed infants exclusively for 6 months',
        'Maintain kitchen hygiene',
      ],
      'urgency': 'Medium — give ORS immediately; seek help if blood in stool or child under 5',
    },
    'tuberculosis': {
      'disease': 'Tuberculosis (TB)',
      'description': 'TB is a bacterial infection that mainly affects the lungs, spread through airborne droplets.',
      'symptoms': ['Persistent cough for 2+ weeks', 'Coughing blood', 'Chest pain', 'Weight loss', 'Night sweats', 'Fever and fatigue'],
      'prevention': [
        'BCG vaccination for children',
        'Complete the full course of TB medication (DOTS)',
        'Cover mouth when coughing',
        'Ensure good ventilation in homes',
        'Avoid close contact with active TB patients',
        'Regular health check-ups',
        'Maintain good nutrition to boost immunity',
      ],
      'urgency': 'High — start DOTS treatment immediately upon diagnosis',
    },
    'diabetes': {
      'disease': 'Diabetes (Type 2)',
      'description': 'A chronic condition where the body cannot properly use insulin, leading to high blood sugar.',
      'symptoms': ['Frequent urination', 'Excessive thirst', 'Unexplained weight loss', 'Fatigue', 'Blurred vision', 'Slow wound healing'],
      'prevention': [
        'Maintain a healthy weight',
        'Exercise for 30 minutes daily',
        'Eat a balanced diet rich in vegetables and whole grains',
        'Limit sugar and refined carbohydrates',
        'Monitor blood sugar regularly',
        'Avoid smoking and excessive alcohol',
        'Regular medical check-ups after age 40',
      ],
      'urgency': 'Medium — manage with diet, exercise, and medication as prescribed',
    },
    'covid': {
      'disease': 'COVID-19',
      'description': 'A respiratory illness caused by the SARS-CoV-2 virus, spread through respiratory droplets.',
      'symptoms': ['Fever', 'Dry cough', 'Tiredness', 'Loss of taste or smell', 'Sore throat', 'Difficulty breathing (severe)'],
      'prevention': [
        'Get vaccinated with all recommended doses',
        'Wear masks in crowded places',
        'Wash hands frequently with soap for 20 seconds',
        'Maintain social distancing',
        'Avoid touching face with unwashed hands',
        'Ensure good ventilation indoors',
        'Isolate if symptomatic',
      ],
      'urgency': 'High if breathing difficulty — seek emergency care immediately',
    },
    'fever': {
      'disease': 'Fever (General)',
      'description': 'An elevated body temperature, usually a sign of infection or illness.',
      'symptoms': ['Body temperature above 100.4°F (38°C)', 'Chills', 'Sweating', 'Headache', 'Muscle aches', 'Weakness'],
      'prevention': [
        'Maintain good hygiene and handwashing',
        'Drink plenty of fluids',
        'Stay up to date on vaccinations',
        'Avoid close contact with sick individuals',
        'Get adequate rest and nutrition',
        'Keep surroundings clean',
        'Seek medical care if fever lasts more than 3 days',
      ],
      'urgency': 'Low-Medium — rest and monitor; consult doctor if persistent',
    },
    'cold': {
      'disease': 'Common Cold',
      'description': 'A viral infection of the upper respiratory tract, usually mild and self-limiting.',
      'symptoms': ['Runny or stuffy nose', 'Sneezing', 'Sore throat', 'Mild cough', 'Low-grade fever', 'Body aches'],
      'prevention': [
        'Wash hands frequently',
        'Avoid touching eyes, nose, and mouth',
        'Stay away from sick individuals',
        'Drink warm fluids like soup or tea',
        'Get adequate sleep',
        'Eat vitamin C-rich fruits',
        'Keep warm in cold weather',
      ],
      'urgency': 'Low — usually resolves in 7-10 days without medication',
    },
    'cough': {
      'disease': 'Cough (Persistent)',
      'description': 'A reflex action to clear the throat and airways, can indicate various conditions.',
      'symptoms': ['Dry or wet cough', 'Throat irritation', 'Chest discomfort', 'Phlegm production', 'Wheezing'],
      'prevention': [
        'Avoid smoking and secondhand smoke',
        'Drink warm water and honey',
        'Use steam inhalation',
        'Keep the air moist with a humidifier',
        'Avoid dust and allergens',
        'Seek medical advice if cough lasts more than 2 weeks',
        'Get tested for TB if cough persists with fever',
      ],
      'urgency': 'Medium if persistent — rule out TB and other conditions',
    },
  };

  void _searchDisease() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a disease or symptom')));
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Search in local database
    Future.delayed(const Duration(milliseconds: 800), () {
      Map<String, dynamic>? found;

      // Direct match
      if (_healthData.containsKey(query)) {
        found = _healthData[query];
      } else {
        // Partial match in disease names or symptoms
        for (final entry in _healthData.entries) {
          final data = entry.value;
          final diseaseName = (data['disease'] as String).toLowerCase();
          final symptoms = (data['symptoms'] as List).map((s) => s.toString().toLowerCase()).toList();

          if (diseaseName.contains(query) || query.contains(entry.key)) {
            found = data;
            break;
          }
          for (final symptom in symptoms) {
            if (symptom.contains(query) || query.contains(symptom.split(' ').first)) {
              found = data;
              break;
            }
          }
          if (found != null) break;
        }
      }

      setState(() {
        _isLoading = false;
        _result = found;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GramAppBar(roleLabel: 'Health Awareness', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Awareness', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
            const SizedBox(height: 6),
            Text('Search for a disease or symptom to learn about preventive measures.', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 20),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'E.g., Malaria, Dengue, Fever...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primaryTeal),
                    ),
                    onSubmitted: (_) => _searchDisease(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _searchDisease,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Search Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Malaria', 'Dengue', 'Typhoid', 'Diarrhea', 'TB', 'Diabetes', 'COVID', 'Fever', 'Cold', 'Cough'].map((disease) {
                return ActionChip(
                  label: Text(disease, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _searchController.text = disease;
                    _searchDisease();
                  },
                  backgroundColor: theme.cardTheme.color,
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Results
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),

            if (_hasSearched && !_isLoading && _result == null)
              _buildNotFound(theme),

            if (_result != null && !_isLoading)
              _buildResultCard(theme, _result!),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: theme.textTheme.bodySmall?.color),
          const SizedBox(height: 12),
          Text('No results found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
          const SizedBox(height: 6),
          Text('Try searching for common diseases like Malaria, Dengue, Typhoid, etc.', style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme, Map<String, dynamic> data) {
    final symptoms = data['symptoms'] as List;
    final prevention = data['prevention'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Disease Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medical_information, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['disease'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(data['description'], style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Urgency
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.warning),
              const SizedBox(width: 10),
              Expanded(child: Text(data['urgency'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color))),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Symptoms
        Text('Symptoms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: symptoms.map<Widget>((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: AppColors.emergencyRed.withOpacity(0.7)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s as String, style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color))),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Prevention
        Text('Preventive Measures', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: prevention.asMap().entries.map<Widget>((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value as String, style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color))),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
