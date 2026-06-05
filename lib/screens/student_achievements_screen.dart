import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/achievement_model.dart';

class StudentAchievementsScreen extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String groupName;

  const StudentAchievementsScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.groupName,
  });

  @override
  State<StudentAchievementsScreen> createState() => _StudentAchievementsScreenState();
}

class _StudentAchievementsScreenState extends State<StudentAchievementsScreen> {
  List<Achievement> _groupFeed = [];
  List<Achievement> _myTrophies = [];
  
  StreamSubscription? _groupSub;
  StreamSubscription? _mySub;

  @override
  void initState() {
    super.initState();
    _groupSub = FirestoreService.instance.getAchievements(groupName: widget.groupName).listen((data) {
      if(mounted) setState(() => _groupFeed = data);
    });
    _mySub = FirestoreService.instance.getAchievements(studentId: widget.studentId).listen((data) {
      if(mounted) setState(() => _myTrophies = data);
    });
  }

  @override
  void dispose() {
    _groupSub?.cancel();
    _mySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: const AssetImage('assets/images/gimnasia_landing.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.95), BlendMode.darken),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Salón de la Fama', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, shadows: const [Shadow(color: Colors.pinkAccent, blurRadius: 10)])),
            backgroundColor: Colors.black.withOpacity(0.5),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            bottom: TabBar(
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              indicatorColor: Colors.pinkAccent,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(icon: Icon(Icons.public), text: 'Feed Comunidad'),
                Tab(icon: Icon(Icons.emoji_events), text: 'Mis Trofeos'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildWallOfFameFeed(context),
              _buildMyTrophies(context),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 1: Muro de la Fama (Fase 8: Feed inmersivo modo Instagram con fotos y reacciones)
  Widget _buildWallOfFameFeed(BuildContext context) {
    final achievements = _groupFeed;

    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Aún no hay logros en el grupo',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _FeedCard(achievement: achievements[index], loggedInStudent: widget.studentName);
      },
    );
  }

  // Tab 2: Mis Trofeos (Logros estáticos en línea del tiempo visual)
  Widget _buildMyTrophies(BuildContext context) {
    final achievements = _myTrophies;

    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text('Aún no tienes logros', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70)),
            const SizedBox(height: 8),
            Text('¡Sigue entrenando para desbloquear trofeos!', style: GoogleFonts.poppins(color: Colors.white54), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isLast = index == achievements.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: achievement.color.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: achievement.color.withOpacity(0.6), blurRadius: 15)],
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Icon(achievement.icon, size: 32, color: Colors.white),
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 80,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [achievement.color.withOpacity(0.5), achievement.color.withOpacity(0.0)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: achievement.color.withOpacity(0.4), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: achievement.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: achievement.color.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: achievement.color),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('dd MMM yyyy').format(achievement.date),
                                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: achievement.color),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(achievement.title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: achievement.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: achievement.color.withOpacity(0.3)),
                                ),
                                child: Text(achievement.typeText, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: achievement.color)),
                              ),
                              const Spacer(),
                              Text(achievement.timeAgo, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeedCard extends StatefulWidget {
  final Achievement achievement;
  final String loggedInStudent;

  const _FeedCard({required this.achievement, required this.loggedInStudent});

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  late Map<String, int> localReactions;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    localReactions = Map.from(widget.achievement.reactions);
  }

  void _addReaction(String type) {
    setState(() {
      localReactions[type] = (localReactions[type] ?? 0) + 1;
    });
    
    // Simulate positive message trigger
    if (type == 'fire') {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('🔥 ¡Comentaste "¡Eres Imparable!" a ${widget.achievement.studentName.split(' ')[0]}!', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
           backgroundColor: Colors.orangeAccent.withOpacity(0.8),
           behavior: SnackBarBehavior.floating,
           duration: const Duration(seconds: 2),
         )
       );
    }
  }

  void _fakeDownloadMemory() async {
    setState(() => isSaving = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate compilation
    if (mounted) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Expanded(child: Text('¡Postal estética guardada en Galería! Lista para Instagram 📸', style: GoogleFonts.poppins(color: Colors.white))),
            ],
          ),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.achievement.memoryPhotoUrl != null;
    final bool isMyAchievement = widget.achievement.studentName == widget.loggedInStudent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CARD
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: widget.achievement.color.withOpacity(0.2),
                      child: Icon(widget.achievement.icon, color: widget.achievement.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.achievement.studentName,
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.achievement.timeAgo,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    if (isMyAchievement)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.pinkAccent),
                        ),
                        child: Text("Tú", style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                      )
                    else 
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white54),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),

              // ACHIEVEMENT TITLE AND BADGES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Text(
                  widget.achievement.title,
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),

              // TAGS OR TYPES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  spacing: 6,
                  children: [
                    _buildChip(widget.achievement.typeText, widget.achievement.color),
                    if (widget.achievement.taggedStudents.isNotEmpty)
                      _buildChip('Con: ${widget.achievement.taggedStudents.length} amigas', Colors.purpleAccent),
                  ],
                ),
              ),

              // IMAGE MEMORY (IF ANY)
              if (hasImage) 
                GestureDetector(
                  onDoubleTap: () => _addReaction('heart'),
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 300),
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.black26),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.achievement.memoryPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           // Fallback robusto nativo para cuando Web CORS bloquea las imágenes de Unsplash en localhost.
                           return Image.asset('assets/images/gimnasia_landing.png', fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                ),

              // SOCIAL REACTIONS FOOTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Row(
                  children: [
                    _ReactionPill(
                      emoji: '❤️', 
                      count: localReactions['heart'] ?? 0, 
                      color: Colors.redAccent,
                      onTap: () => _addReaction('heart'),
                    ),
                    const SizedBox(width: 8),
                    _ReactionPill(
                      emoji: '🔥', 
                      count: localReactions['fire'] ?? 0, 
                      color: Colors.orangeAccent,
                      onTap: () => _addReaction('fire'),
                      onLongPress: () => _addReaction('fire'), // Triggers the compliment message in _addReaction
                    ),
                    const SizedBox(width: 8),
                    _ReactionPill(
                      emoji: '🥇', 
                      count: localReactions['medal'] ?? 0, 
                      color: Colors.amberAccent,
                      onTap: () => _addReaction('medal'),
                    ),
                    const Spacer(),
                    
                    if (hasImage)
                      isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                        : IconButton(
                            icon: const Icon(Icons.download_for_offline, color: Colors.cyanAccent, size: 28),
                            tooltip: 'Guardar Recuerdo (Postal)',
                            onPressed: _fakeDownloadMemory,
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _ReactionPill extends StatelessWidget {
  final String emoji;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ReactionPill({
    required this.emoji,
    required this.count,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: count > 0 ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: count > 0 ? color.withOpacity(0.5) : Colors.white24),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
