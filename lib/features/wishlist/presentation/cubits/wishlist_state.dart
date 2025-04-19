// lib/features/wishlist/presentation/cubits/wishlist_state.dart

import 'package:equatable/equatable.dart';
import 'package:hostations_commerce/features/wishlist/domain/models/wishlist_item.dart';

enum WishlistStatus { initial, loading, success, failure }

class WishlistState extends Equatable {
  final WishlistStatus status;
  final List<WishlistItem> items;
  final List<String> favoriteIds;
  final String? errorMessage;
  final bool isAddingToWishlist;
  final bool isRemovingFromWishlist;
  final String? processingProductId;

  const WishlistState({
    this.status = WishlistStatus.initial,
    this.items = const [],
    this.favoriteIds = const [],
    this.errorMessage,
    this.isAddingToWishlist = false,
    this.isRemovingFromWishlist = false,
    this.processingProductId,
  });

  bool isFavorite(String id) => favoriteIds.contains(id);

  bool isProcessing(String id) => processingProductId == id;

  @override
  List<Object?> get props => [
        status,
        items,
        favoriteIds,
        errorMessage,
        isAddingToWishlist,
        isRemovingFromWishlist,
        processingProductId,
      ];

  WishlistState copyWith({
    WishlistStatus? status,
    List<WishlistItem>? items,
    List<String>? favoriteIds,
    String? errorMessage,
    bool? isAddingToWishlist,
    bool? isRemovingFromWishlist,
    String? processingProductId,
    bool clearProcessingProductId = false,
  }) {
    return WishlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: errorMessage,
      isAddingToWishlist: isAddingToWishlist ?? this.isAddingToWishlist,
      isRemovingFromWishlist: isRemovingFromWishlist ?? this.isRemovingFromWishlist,
      processingProductId: clearProcessingProductId ? null : processingProductId ?? this.processingProductId,
    );
  }
}
