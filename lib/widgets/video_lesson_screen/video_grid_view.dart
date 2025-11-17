// import 'package:flutter/material.dart';
// import 'video_card.dart'; // Imports the newly created VideoCard

// class VideoListView extends StatelessWidget {
//   const VideoListView({Key? key}) : super(key: key);

//   // Hardcoded Data List, updated to match the screenshot
//   final List<Map<String, String>> videos = const [
//     {
//       'title': 'sample video:jvhhjvhhjvhkj',
//       'description': 'this is a sample video',
//       'author': 'teacher123',
//       'date': '11/08/2025',
//       'classTag': 'Sipta - Tangalle',
//       'yearTag': 'Year 12',
//     },
//     {
//       'title': 'python video',
//       'description': 'this is a python course for beginner',
//       'author': 'Teacher',
//       'date': '16/08/2025',
//       'classTag': 'Sipta - Tangalle',
//       'yearTag': 'Year 12',
//     },
//     {
//       'title': 'sampel voide',
//       'description': 'this is a sample video',
//       'author': 'Teacher',
//       'date': '16/08/2025',
//       'classTag': 'Sipta - Tangalle',
//       'yearTag': 'Year 12',
//     },
//     {
//       'title': 'hvc',
//       'description': 'no description available',
//       'author': 'hansaka',
//       'date': '09/10/2025',
//       'classTag': 'Sipta - Tangalle',
//       'yearTag': 'Year 12',
//     },
//     {
//       'title': 'IOT',
//       'description': 'sample description',
//       'author': 'hansaka',
//       'date': '09/10/2025',
//       'classTag': 'Sipta - Tangalle',
//       'yearTag': 'Year 12',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // Uses SliverGrid to create a Grid Layout in CustomScrollView
//     return SliverGrid.builder(
//       itemCount: videos.length,
//       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 350, // Maximum width of a card in one row
//         mainAxisSpacing: 16.0,
//         crossAxisSpacing: 16.0,
//         childAspectRatio: 0.65, // Card's height/width aspect ratio.
//       ),
//       itemBuilder: (context, index) {
//         final video = videos[index];
//         return VideoCard(
//           title: video['title']!,
//           description: video['description']!,
//           author: video['author']!,
//           date: video['date']!,
//           classTag: video['classTag']!,
//           yearTag: video['yearTag']!,
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:lms_app/widgets/video_lesson_screen/video_card_lesson.dart';

class VideoGridView extends StatelessWidget {
  const VideoGridView({Key? key}) : super(key: key);

  final List<Map<String, String>> videos = const [
    {
      'title': 'sample video.jvhvjhvhjkv',
      'description': 'thi sis a sampe vudeo',
      'teacher': 'teacher123',
      'date': '11/08/2025',
      'subject': 'Sipta - Tangalle',
      'year': 'Year 12',
    },
    {
      'title': 'python video',
      'description': 'thisis a python course for beginner',
      'teacher': 'Teacher',
      'date': '16/08/2025',
      'subject': 'Sipta - Tangalle',
      'year': 'Year 12',
    },
    {
      'title': 'sampel voide',
      'description': 'this is a sampe vudei',
      'teacher': 'Teacher',
      'date': '16/08/2025',
      'subject': 'Sipta - Tangalle',
      'year': 'Year 12',
    },
    {
      'title': 'hvc',
      'description': 'No description available',
      'teacher': 'hansaka',
      'date': '09/10/2025',
      'subject': 'Sipta - Tangalle',
      'year': 'Year 12',
    },
    {
      'title': 'IOT',
      'description': 'sample description',
      'teacher': 'hansaka',
      'date': '09/10/2025',
      'subject': 'Sipta - Tangalle',
      'year': 'Year 12',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 💡 Responsive Grid Layout
    return SliverGrid.builder(
      itemCount: videos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,

        // maxCrossAxisExtent: 375, // එක් card එකක උපරිම පළල
        mainAxisSpacing: 20.0,
        childAspectRatio:
            0.94, // Card's height/width aspect ratio. (to match the screenshot)
      ),
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoCard(
          title: video['title']!,
          description: video['description']!,
          teacher: video['teacher']!,
          date: video['date']!,
          author: video['subject']!,
          year: video['year']!,
        );
      },
    );
  }
}
