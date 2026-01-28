  import 'dart:math';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  class RandomIdentityGeneratorPage extends StatefulWidget {
    const RandomIdentityGeneratorPage({super.key});

    @override
    State<RandomIdentityGeneratorPage> createState() =>
        _RandomIdentityGeneratorPageState();
  }

  class _RandomIdentityGeneratorPageState
      extends State<RandomIdentityGeneratorPage> {
    Map<String, String> _identity = {};
    String _selectedGender = 'Random';
    String _selectedCountry = 'United States';

    // United States Data
    final List<String> _usMaleFirstNames = [
      'James',
      'John',
      'Robert',
      'Michael',
      'William',
      'David',
      'Richard',
      'Joseph',
      'Thomas',
      'Charles',
      'Christopher',
      'Daniel',
      'Matthew',
      'Anthony',
      'Mark',
      'Donald',
      'Steven',
      'Paul',
      'Andrew',
      'Joshua',
    ];

    final List<String> _usFemaleFirstNames = [
      'Mary',
      'Patricia',
      'Jennifer',
      'Linda',
      'Elizabeth',
      'Barbara',
      'Susan',
      'Jessica',
      'Sarah',
      'Karen',
      'Lisa',
      'Nancy',
      'Betty',
      'Margaret',
      'Sandra',
      'Ashley',
      'Kimberly',
      'Emily',
      'Donna',
      'Michelle',
    ];

    final List<String> _usLastNames = [
      'Smith',
      'Johnson',
      'Williams',
      'Brown',
      'Jones',
      'Garcia',
      'Miller',
      'Davis',
      'Rodriguez',
      'Martinez',
      'Hernandez',
      'Lopez',
      'Wilson',
      'Anderson',
      'Thomas',
      'Taylor',
      'Moore',
      'Jackson',
      'Martin',
      'Lee',
    ];

    final List<String> _usCities = [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
      'Philadelphia',
      'San Antonio',
      'San Diego',
      'Dallas',
      'San Jose',
      'Austin',
      'Seattle',
    ];

    final Map<String, List<String>> _usStateZips = {
      'California': ['90001', '91001', '92101', '93001', '94102'],
      'New York': ['10001', '11201', '12201', '13201'],
      'Texas': ['75001', '76001', '77001', '78701'],
      'Florida': ['32101', '33101', '34101'],
      'Illinois': ['60601', '61801'],
    };

    // Germany Data
    final List<String> _deMaleFirstNames = [
      'Lukas',
      'Leon',
      'Tim',
      'Paul',
      'Jonas',
      'Finn',
      'Felix',
      'Max',
      'Elias',
      'Noah',
      'Ben',
      'Louis',
      'Henry',
      'Julian',
      'Moritz',
    ];

    final List<String> _deFemaleFirstNames = [
      'Emma',
      'Mia',
      'Hannah',
      'Sofia',
      'Anna',
      'Emilia',
      'Lina',
      'Marie',
      'Lena',
      'Lea',
      'Leonie',
      'Amelie',
      'Sophie',
      'Charlotte',
      'Laura',
    ];

    final List<String> _deLastNames = [
      'Müller',
      'Schmidt',
      'Schneider',
      'Fischer',
      'Weber',
      'Meyer',
      'Wagner',
      'Becker',
      'Schulz',
      'Hoffmann',
      'Schäfer',
      'Koch',
      'Bauer',
      'Richter',
      'Klein',
      'Wolf',
      'Schröder',
      'Neumann',
      'Schwarz',
      'Zimmermann',
    ];

    final List<String> _deCities = [
      'Berlin',
      'Hamburg',
      'München',
      'Köln',
      'Frankfurt',
      'Stuttgart',
      'Düsseldorf',
      'Dortmund',
      'Essen',
      'Leipzig',
      'Bremen',
      'Dresden',
    ];

    final Map<String, List<String>> _deStateZips = {
      'Berlin': ['10115', '10117', '10178', '10243'],
      'Hamburg': ['20095', '20144', '20251', '20354'],
      'Bayern': ['80331', '80335', '80469', '81539'],
      'Nordrhein-Westfalen': ['40210', '44135', '45127', '50667'],
    };

    // Indonesia Data
    final List<String> _idMaleFirstNames = [
      'Budi',
      'Ahmad',
      'Andi',
      'Agus',
      'Rizki',
      'Dedi',
      'Hendra',
      'Eko',
      'Bambang',
      'Joko',
      'Rudi',
      'Iwan',
      'Ade',
      'Surya',
      'Fajar',
    ];

    final List<String> _idFemaleFirstNames = [
      'Siti',
      'Dewi',
      'Sri',
      'Rina',
      'Nur',
      'Ani',
      'Fitri',
      'Maya',
      'Ratna',
      'Indah',
      'Wati',
      'Yanti',
      'Lina',
      'Ayu',
      'Putri',
    ];

    final List<String> _idLastNames = [
      'Wijaya',
      'Santoso',
      'Pratama',
      'Kusuma',
      'Saputra',
      'Permana',
      'Setiawan',
      'Nugroho',
      'Hidayat',
      'Firmansyah',
      'Rahman',
      'Utomo',
      'Suryanto',
      'Gunawan',
      'Putra',
      'Wahyudi',
      'Hartono',
      'Susanto',
    ];

    final List<String> _idCities = [
      'Jakarta',
      'Surabaya',
      'Bandung',
      'Medan',
      'Semarang',
      'Makassar',
      'Palembang',
      'Tangerang',
      'Depok',
      'Bekasi',
      'Bogor',
      'Yogyakarta',
    ];

    final Map<String, List<String>> _idProvinceZips = {
      'Jakarta': ['10110', '11410', '12710', '13220'],
      'Jawa Barat': ['40111', '16121', '17141'],
      'Jawa Timur': ['60111', '61511', '65111'],
      'Sumatera Utara': ['20111', '20371'],
    };

    final List<String> _streetNames = [
      'Main',
      'Oak',
      'Pine',
      'Maple',
      'Park',
      'Washington',
      'Lake',
      'Hill',
      'Spring',
      'Forest',
      'River',
      'Sunset',
      'Madison',
      'Lincoln',
    ];

    final List<String> _deStreetNames = [
      'Haupt',
      'Bahnhof',
      'Kirch',
      'Schul',
      'Markt',
      'Berg',
      'Wald',
      'Garten',
      'König',
      'Kaiser',
      'Post',
      'Bismarck',
      'Goethe',
    ];

    final List<String> _idStreetNames = [
      'Jalan Sudirman',
      'Jalan Gatot Subroto',
      'Jalan Diponegoro',
      'Jalan Ahmad Yani',
      'Jalan Thamrin',
      'Jalan Kuningan',
      'Jalan Merdeka',
      'Jalan Raya',
      'Jalan Veteran',
      'Jalan Pemuda',
    ];

    final List<String> _emailDomains = [
      'gmail.com',
      '@proton.me',
      '@tutanota.com',
      '@fastmail.com',
      '@posteo.de',
      '@mailbox.org',
      '@runbox.com',
      '@mailfence.com',
      '@disroot.org',
      '@ctemplar.com',
      '@cock.li',
      '@airmail.cc',
      '@mail.com',
      '@gmx.com',
      '@yandex.com',
      '@zoho.com',
      '@inbox.com',
      '@lycos.com',
      '@rediffmail.com',
      '@mail.ru',
      '@privateemail.com',
    ];

    void _generateIdentity() {
      final random = Random();

      // Determine gender
      String gender = _selectedGender;
      if (gender == 'Random') {
        gender = random.nextBool() ? 'Male' : 'Female';
      }

      Map<String, String> identity = {};

      switch (_selectedCountry) {
        case 'United States':
          identity = _generateUSIdentity(random, gender);
          break;
        case 'Germany':
          identity = _generateGermanyIdentity(random, gender);
          break;
        case 'Indonesia':
          identity = _generateIndonesiaIdentity(random, gender);
          break;
      }

      setState(() {
        _identity = identity;
      });
    }

    Map<String, String> _generateUSIdentity(Random random, String gender) {
      // Generate name
      final firstName = gender == 'Male'
          ? _usMaleFirstNames[random.nextInt(_usMaleFirstNames.length)]
          : _usFemaleFirstNames[random.nextInt(_usFemaleFirstNames.length)];
      final lastName = _usLastNames[random.nextInt(_usLastNames.length)];
      final fullName = '$firstName $lastName';

      // Generate date of birth
      final age = 18 + random.nextInt(63);
      final birthYear = DateTime.now().year - age;
      final birthMonth = 1 + random.nextInt(12);
      final birthDay = 1 + random.nextInt(28);
      final dob =
          '${birthMonth.toString().padLeft(2, '0')}/${birthDay.toString().padLeft(2, '0')}/$birthYear';

      // Generate address
      final streetNumber = 100 + random.nextInt(9900);
      final streetName = _streetNames[random.nextInt(_streetNames.length)];
      final streetTypes = ['Street', 'Avenue', 'Road', 'Lane', 'Drive'];
      final streetType = streetTypes[random.nextInt(streetTypes.length)];
      final address = '$streetNumber $streetName $streetType';

      // Generate city, state, zip
      final state = _usStateZips.keys
          .toList()[random.nextInt(_usStateZips.length)];
      final city = _usCities[random.nextInt(_usCities.length)];
      final zipCodes = _usStateZips[state]!;
      final zipCode = zipCodes[random.nextInt(zipCodes.length)];

      // Generate phone number (US format)
      final areaCode = 200 + random.nextInt(800);
      final prefix = 200 + random.nextInt(800);
      final lineNumber = 1000 + random.nextInt(9000);
      final phone = '($areaCode) $prefix-$lineNumber';

      // Generate email
      final emailName =
          '${firstName.toLowerCase()}.${lastName.toLowerCase()}${random.nextInt(999)}';
      final emailDomain = _emailDomains[random.nextInt(_emailDomains.length)];
      final email = '$emailName$emailDomain';

      // Generate username
      final username =
          '${firstName.toLowerCase()}${lastName[0].toLowerCase()}${random.nextInt(9999)}';

      // Generate SSN (fake format)
      final ssn1 = 100 + random.nextInt(900);
      final ssn2 = 10 + random.nextInt(90);
      final ssn3 = 1000 + random.nextInt(9000);
      final ssn = '$ssn1-$ssn2-$ssn3';

      return {
        'Full Name': fullName,
        'First Name': firstName,
        'Last Name': lastName,
        'Gender': gender,
        'Date of Birth': dob,
        'Age': age.toString(),
        'Address': address,
        'City': city,
        'State': state,
        'ZIP Code': zipCode,
        'Phone': phone,
        'Email': email,
        'Username': username,
        'SSN': ssn,
        'Country': 'United States',
      };
    }

    Map<String, String> _generateGermanyIdentity(Random random, String gender) {
      // Generate name
      final firstName = gender == 'Male'
          ? _deMaleFirstNames[random.nextInt(_deMaleFirstNames.length)]
          : _deFemaleFirstNames[random.nextInt(_deFemaleFirstNames.length)];
      final lastName = _deLastNames[random.nextInt(_deLastNames.length)];
      final fullName = '$firstName $lastName';

      // Generate date of birth (European format)
      final age = 18 + random.nextInt(63);
      final birthYear = DateTime.now().year - age;
      final birthMonth = 1 + random.nextInt(12);
      final birthDay = 1 + random.nextInt(28);
      final dob =
          '${birthDay.toString().padLeft(2, '0')}.${birthMonth.toString().padLeft(2, '0')}.$birthYear';

      // Generate address (German format)
      final streetName = _deStreetNames[random.nextInt(_deStreetNames.length)];
      final streetNumber = 1 + random.nextInt(200);
      final address = '${streetName}straße $streetNumber';

      // Generate city, state, zip
      final state = _deStateZips.keys
          .toList()[random.nextInt(_deStateZips.length)];
      final city = _deCities[random.nextInt(_deCities.length)];
      final zipCodes = _deStateZips[state]!;
      final zipCode = zipCodes[random.nextInt(zipCodes.length)];

      // Generate phone number (German format)
      final areaCode = 30 + random.nextInt(970);
      final mainNumber = 10000000 + random.nextInt(90000000);
      final phone = '+49 $areaCode $mainNumber';

      // Generate email
      final emailName =
          '${firstName.toLowerCase()}.${lastName.toLowerCase()}${random.nextInt(999)}';
      final emailDomain = _emailDomains[random.nextInt(_emailDomains.length)];
      final email = '$emailName$emailDomain';

      // Generate username
      final username =
          '${firstName.toLowerCase()}${lastName[0].toLowerCase()}${random.nextInt(9999)}';

      // Generate Personalausweisnummer (ID number - fake format)
      final idNumber =
          'L${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}';

      return {
        'Full Name': fullName,
        'First Name': firstName,
        'Last Name': lastName,
        'Gender': gender,
        'Date of Birth': dob,
        'Age': age.toString(),
        'Address': address,
        'City': city,
        'State': state,
        'Postal Code': zipCode,
        'Phone': phone,
        'Email': email,
        'Username': username,
        'ID Number': idNumber,
        'Country': 'Germany',
      };
    }

    Map<String, String> _generateIndonesiaIdentity(Random random, String gender) {
      // Generate name
      final firstName = gender == 'Male'
          ? _idMaleFirstNames[random.nextInt(_idMaleFirstNames.length)]
          : _idFemaleFirstNames[random.nextInt(_idFemaleFirstNames.length)];
      final lastName = _idLastNames[random.nextInt(_idLastNames.length)];
      final fullName = '$firstName $lastName';

      // Generate date of birth (DD-MM-YYYY)
      final age = 18 + random.nextInt(63);
      final birthYear = DateTime.now().year - age;
      final birthMonth = 1 + random.nextInt(12);
      final birthDay = 1 + random.nextInt(28);
      final dob =
          '${birthDay.toString().padLeft(2, '0')}-${birthMonth.toString().padLeft(2, '0')}-$birthYear';

      // Generate address (Indonesian format)
      final streetName = _idStreetNames[random.nextInt(_idStreetNames.length)];
      final streetNumber = 1 + random.nextInt(200);
      final address = '$streetName No. $streetNumber';

      // Generate city, province, zip
      final province = _idProvinceZips.keys
          .toList()[random.nextInt(_idProvinceZips.length)];
      final city = _idCities[random.nextInt(_idCities.length)];
      final zipCodes = _idProvinceZips[province]!;
      final zipCode = zipCodes[random.nextInt(zipCodes.length)];

      // Generate phone number (Indonesian format)
      final operator = [
        '812',
        '813',
        '821',
        '822',
        '851',
        '852',
      ][random.nextInt(6)];
      final mainNumber = 10000000 + random.nextInt(90000000);
      final phone = '+62 $operator-$mainNumber';

      // Generate email
      final emailName =
          '${firstName.toLowerCase()}.${lastName.toLowerCase()}${random.nextInt(999)}';
      final emailDomain = _emailDomains[random.nextInt(_emailDomains.length)];
      final email = '$emailName$emailDomain';

      // Generate username
      final username =
          '${firstName.toLowerCase()}${lastName[0].toLowerCase()}${random.nextInt(9999)}';

      // Generate NIK (fake format: 16 digits)
      final nik = List.generate(16, (_) => random.nextInt(10)).join();

      return {
        'Full Name': fullName,
        'First Name': firstName,
        'Last Name': lastName,
        'Gender': gender,
        'Date of Birth': dob,
        'Age': age.toString(),
        'Address': address,
        'City': city,
        'Province': province,
        'Postal Code': zipCode,
        'Phone': phone,
        'Email': email,
        'Username': username,
        'NIK': nik,
        'Country': 'Indonesia',
      };
    }

    void _copyField(String value) {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied: $value'),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    void _copyAll() {
      final allData = _identity.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
      Clipboard.setData(ClipboardData(text: allData));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All data copied!')));
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);

      return Scaffold(
        appBar: AppBar(title: const Text('Random Identity Generator')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Settings Section
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surface,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Settings',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Country', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'United States',
                              label: Text('🇺🇸 US'),
                            ),
                            ButtonSegment(
                              value: 'Germany',
                              label: Text('🇩🇪 DE'),
                            ),
                            ButtonSegment(
                              value: 'Indonesia',
                              label: Text('🇮🇩 ID'),
                            ),
                          ],
                          selected: {_selectedCountry},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedCountry = newSelection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('Gender', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Random',
                              label: Text('Random'),
                              icon: Icon(Icons.shuffle, size: 16),
                            ),
                            ButtonSegment(
                              value: 'Male',
                              label: Text('Male'),
                              icon: Icon(Icons.male, size: 16),
                            ),
                            ButtonSegment(
                              value: 'Female',
                              label: Text('Female'),
                              icon: Icon(Icons.female, size: 16),
                            ),
                          ],
                          selected: {_selectedGender},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedGender = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Generate Button
            FilledButton.icon(
              onPressed: _generateIdentity,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Identity'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Generated Identity Section
            if (_identity.isNotEmpty) ...[
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.surface,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Generated Identity',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy_all, size: 20),
                            onPressed: _copyAll,
                            tooltip: 'Copy All',
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    ..._identity.entries.map((entry) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              entry.key,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                entry.value,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontFamily:
                                      entry.key == 'Email' ||
                                          entry.key == 'Username' ||
                                          entry.key == 'SSN' ||
                                          entry.key == 'NIK' ||
                                          entry.key == 'ID Number'
                                      ? 'monospace'
                                      : null,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () => _copyField(entry.value),
                            ),
                          ),
                          if (entry.key != _identity.entries.last.key)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: theme.colorScheme.outlineVariant,
                            ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      );
    }
  }
