//flutter run -d web-server --web-hostname=0.0.0.0 --web-port=1213
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const TinderDemoApp());
}

class TinderDemoApp extends StatelessWidget {
  const TinderDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tinder-like Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Profile {
  final String name;
  final int age;
  final String bio;
  final String image;

  const Profile({
    required this.name,
    required this.age,
    required this.bio,
    required this.image,
  });
}

const demoProfiles = <Profile>[
  Profile(
    name: 'Alejandra',
    age: 26,
    bio: '"No soy exigente con la altura que mides, todos tienen la misma altura en la cama 🤷🏻♀️"',
    image: 'assets/lazaro.jpeg',
  ),
  Profile(
    name: 'Juanjo',
    age: 42,
    bio: '"Si me das tu mejor sonrisa, prometo enseñarte lo que puedo hacer con las manos… y no hablo de cocina.😏"',
    image: 'assets/lucia.jpeg',
  ),  
  Profile(
    name: 'Marta',
    age: 23,
    bio: '"yoga, mindfulness y healthyfood? entonces eres bienvenido en mi squad. Busco plan de fin de semana!"',
    image: 'assets/ale.jpeg',
  ),
  Profile(
    name: 'Lydia',
    age: 31,
    bio: '"Si tus plantas pueden sobrevivir sin mí, tal vez nosotros también podemos pasar un buen rato… solo risas y tofu, prometido🌱😏"',
    image: 'assets/sergio.jpeg',
  ), 
  Profile(
    name: 'Wang Jun',
    age: 24,
    bio: '"Soy tan torpe que si esto fuera un anime, ya me habría tropezado con mis propias palabras… pero al menos puedo prometerte buenas risas"',
    image: 'assets/laia.jpeg',
  ), 
  Profile(
    name: 'Bruno',
    age: 32,
    bio: '"Si quieres, puedo debatir contigo sobre igualdad de género mientras te preparo un smoothie vegano y sin gluten"',
    image: 'assets/bea.jpeg',
  ),
  
  Profile(
    name: 'Noa',
    age: 26,
    bio: '"Amante de las bibliotecas, de los lattes helados y, quizás, de ti 😉"',
    image: 'assets/guille.jpeg',
  ),

];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<Profile> _profiles = List.of(demoProfiles);
  Offset _dragOffset = Offset.zero;
  double _angle = 0; // in radians
  bool _isDragging = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _dragOffset += details.delta;
      final center = size.center(Offset.zero);
      final x = _dragOffset.dx;
      _angle = (20 * math.pi / 180) * (x / center.dx).clamp(-1, 1); // max 20º
    });
  }

  void _onDragEnd(Size size) {
    setState(() => _isDragging = false);
    final threshold = size.width * 0.28; // how far to count as a swipe
    final dx = _dragOffset.dx;

    if (dx.abs() >= threshold) {
      final isLike = dx > 0;
      _animateOut(isLike ? size.width : -size.width);
    } else {
      _resetPosition();
    }
  }

  void _animateOut(double targetX) {
    // animate the card out of the screen then remove it
    final begin = _dragOffset;
    final end = Offset(targetX * 1.2, _dragOffset.dy);
    final beginAngle = _angle;
    final endAngle = _angle.sign * 0.35; // ~20º

    final animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Create animations first, then attach listeners (avoid referencing vars before init)
    final offsetAnim = Tween<Offset>(begin: begin, end: end).animate(animation);
    final angleAnim = Tween<double>(begin: beginAngle, end: endAngle).animate(animation);

    offsetAnim.addListener(() => setState(() => _dragOffset = offsetAnim.value));
    angleAnim.addListener(() => setState(() => _angle = angleAnim.value));

    _controller.forward(from: 0).whenComplete(() {
      _removeTopCard(liked: targetX > 0);
    });
  }

  void _resetPosition() {
    final animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    final offsetAnim = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(animation);
    final angleAnim = Tween<double>(begin: _angle, end: 0.0).animate(animation);

    offsetAnim.addListener(() => setState(() => _dragOffset = offsetAnim.value));
    angleAnim.addListener(() => setState(() => _angle = angleAnim.value));

    _controller.forward(from: 0);
  }

  void _removeTopCard({required bool liked}) {
    if (_profiles.isEmpty) return;

    final removed = _profiles.first;
    setState(() {
      _profiles.removeAt(0);
      _dragOffset = Offset.zero;
      _angle = 0;
    });

    debugPrint('${liked ? 'LIKE' : 'NOPE'} → ${removed.name}');

    // 👇 Lógica especial para Bruno
    if (liked && removed.name == 'Bruno') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Pregunta seria'),
              content: const Text('¿Eres Guille?'),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Sí'),
                  onPressed: () {
                    Navigator.of(context).pop();

                    // 👇 Segundo popup si dice que sí
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('¡Ajá!'),
                          content: const Text(
                            'Pillín… incluso del otro género smasheas a la Bea 😏',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Jajaja'),
                              onPressed: () {
                                Navigator.of(context).pop();
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
      });
    }
  }

  void _swipeLeft() => _animateOut(-MediaQuery.of(context).size.width);
  void _swipeRight() => _animateOut(MediaQuery.of(context).size.width);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        backgroundColor: Colors.white, // Fondo blanco
        toolbarHeight: 130, // Altura personalizada del AppBar
          
        leading: IconButton(
          icon: const Icon(Icons.settings),
          color: Colors.grey[800], // Icono en la izquierda
          onPressed: () {
            // Acción del chat
          },
        ),

        centerTitle: true, // Centrar el logo
        title: Image.asset(
          'assets/logotinder.jpg',
          height: 130, // Ajusta según quieras que se vea el logo
        ),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outlined),
            color: Colors.grey[800], // Color del icono
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Chat'),
                    content: const Text('No hay matches todavía... deja de intentarlo'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el pop-up
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      
      ),


      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Card stack
              Expanded(
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (_profiles.length >= 2)
                        Positioned(
                          top: 20,
                          child: Transform.scale(
                            scale: 0.95,
                            child: _ProfileCard(
                              profile: _profiles[1],
                              width: size.width - 32,
                              height: size.height * 0.65,
                            ),
                          ),
                        ),
                      if (_profiles.isNotEmpty)
                        _buildDraggableTopCard(size),
                      if (_profiles.isEmpty)
                        SizedBox(
                          width: size.width,
                          child: const Center(
                            child: Text(
                              'No hay más perfiles',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Bottom actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundActionButton(
                    icon: Icons.close,
                    onPressed: _swipeLeft,
                    tooltip: 'Nope',
                    color: Colors.red,
                  ),
                  _RoundActionButton(
                    icon: Icons.favorite,
                    onPressed: _swipeRight,
                    tooltip: 'Like',
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableTopCard(Size size) {
    final profile = _profiles.first;

    // Like/Nope opacity based on horizontal drag
    final likeOpacity = (_dragOffset.dx / (size.width * 0.25)).clamp(0.0, 1.0);
    final nopeOpacity = (-_dragOffset.dx / (size.width * 0.25)).clamp(0.0, 1.0);

    return Align(
      child: GestureDetector(
        onPanStart: _onDragStart,
        onPanUpdate: (d) => _onDragUpdate(d, size),
        onPanEnd: (_) => _onDragEnd(size),
        child: AnimatedContainer(
          duration: _isDragging ? Duration.zero : const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(_dragOffset.dx, _dragOffset.dy)
            ..rotateZ(_angle),
          child: Stack(
            children: [
              _ProfileCard(
                profile: profile,
                width: size.width - 32,
                height: size.height * 0.7,
              ),

              // LIKE badge
              Positioned(
                top: 24,
                left: 24,
                child: Opacity(
                  opacity: likeOpacity,
                  child: _DecisionBadge(text: 'LIKE', color: Colors.green),
                ),
              ),

              // NOPE badge
              Positioned(
                top: 24,
                right: 24,
                child: Opacity(
                  opacity: nopeOpacity,
                  child: _DecisionBadge(text: 'NOPE', color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Profile profile;
  final double width;
  final double height;

  const _ProfileCard({
    required this.profile,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              profile.image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, size: 48),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black54,
                    Colors.black87,
                  ],
                ),
              ),
            ),

            // Info bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${profile.name}, ${profile.age}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _DecisionBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -12 * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
   final Color color;

  const _RoundActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: RawMaterialButton(
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 64, height: 64),
        shape: const CircleBorder(),
        elevation: 2,
        fillColor: Colors.white,
        child: Icon(icon, size: 35, color: color),
      ),
    );
  }
}
