import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Display a single review
class ReviewCard extends StatelessWidget {
  final String clientName;
  final int rating;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isVerified;
  final VoidCallback? onDelete;
  final String? currentUserId;
  final String? reviewAuthorId;

  const ReviewCard({
    Key? key,
    required this.clientName,
    required this.rating,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isVerified = false,
    this.onDelete,
    this.currentUserId,
    this.reviewAuthorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canDelete = currentUserId == reviewAuthorId;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete review',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStarRating(rating),
                const SizedBox(width: 8),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.amber[600],
          ),
        );
      }),
    );
  }
}

/// Rating input widget
class RatingSelector extends StatefulWidget {
  final Function(int) onRatingChanged;
  final int initialRating;

  const RatingSelector({
    Key? key,
    required this.onRatingChanged,
    this.initialRating = 0,
  }) : super(key: key);

  @override
  State<RatingSelector> createState() => _RatingSelectorState();
}

class _RatingSelectorState extends State<RatingSelector> {
  late int _selectedRating;
  late int _hoverRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
    _hoverRating = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isFilled = rating <= (_hoverRating > 0 ? _hoverRating : _selectedRating);
            return MouseRegion(
              onEnter: (_) => setState(() => _hoverRating = rating),
              onExit: (_) => setState(() => _hoverRating = 0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedRating = rating);
                  widget.onRatingChanged(rating);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber[600],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedRating > 0
              ? _getRatingLabel(_selectedRating)
              : 'Select your rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

/// Display rating statistics
class RatingStatsWidget extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int>? ratingDistribution;

  const RatingStatsWidget({
    Key? key,
    required this.averageRating,
    required this.totalReviews,
    this.ratingDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: Colors.amber[600],
                      );
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 24),
            if (ratingDistribution != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(5, (index) {
                    final rating = 5 - index;
                    final count = ratingDistribution![rating] ?? 0;
                    final percentage = totalReviews > 0
                        ? (count / totalReviews * 100).round()
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text('$rating'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$percentage%', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Write review form
class ReviewFormWidget extends StatefulWidget {
  final Function(int, String, String) onSubmit;
  final bool isLoading;

  const ReviewFormWidget({
    Key? key,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  late int _rating;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _rating = 0;
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate your experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            RatingSelector(
              initialRating: _rating,
              onRatingChanged: (rating) {
                setState(() => _rating = rating);
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Review Title',
                hintText: 'Sum up your experience',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 1,
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Your Review',
                hintText: 'Share details about your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 5,
              maxLength: 1000,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                  if (_rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a rating')),
                    );
                    return;
                  }
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                    return;
                  }
                  if (_contentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please write your review')),
                    );
                    return;
                  }
                  widget.onSubmit(
                    _rating,
                    _titleController.text.trim(),
                    _contentController.text.trim(),
                  );
                },
                child: widget.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}