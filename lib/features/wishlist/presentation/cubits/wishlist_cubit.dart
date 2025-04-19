import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_state.dart';
import 'package:hostations_commerce/features/wishlist/domain/repository/wishlist_repository.dart';
import 'package:hostations_commerce/features/wishlist/presentation/cubits/wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _wishlistRepository;

  WishlistCubit({
    required WishlistRepository wishlistRepository,
  })  : _wishlistRepository = wishlistRepository,
        super(const WishlistState());

  // Initialize wishlist data
  Future<void> loadWishlist() async {
    emit(state.copyWith(status: WishlistStatus.loading));

    try {
      // Load favorite IDs first (faster operation)
      final favoriteIds = await _wishlistRepository.getFavoriteIds();
      emit(state.copyWith(favoriteIds: favoriteIds));

      // Then load full wishlist items
      final items = await _wishlistRepository.getFavorites();
      emit(state.copyWith(
        status: WishlistStatus.success,
        items: items,
      ));
    } catch (e) {
      log('Error loading wishlist: $e');
      emit(state.copyWith(
        status: WishlistStatus.failure,
        errorMessage: 'Failed to load wishlist: $e',
      ));
    }
  }

  // Add product to wishlist
  Future<void> addToWishlist(String id) async {
    // Check if already in wishlist
    if (state.isFavorite(id)) {
      return; // Already in wishlist
    }

    // Set processing state
    emit(state.copyWith(
      isAddingToWishlist: true,
      processingProductId: id,
    ));

    try {
      final success = await _wishlistRepository.addToFavorites(id);

      if (success) {
        // Update local state immediately for better UX
        final updatedFavoriteIds = List<String>.from(state.favoriteIds)..add(id);

        emit(state.copyWith(
          favoriteIds: updatedFavoriteIds,
          isAddingToWishlist: false,
          clearProcessingProductId: true,
        ));

        // Reload full wishlist in background
        loadWishlist();

        DependencyInjector().snackBarService.showSuccess('Added to wishlist');
      } else {
        emit(state.copyWith(
          isAddingToWishlist: false,
          clearProcessingProductId: true,
          errorMessage: 'Failed to add to wishlist',
        ));

        DependencyInjector().snackBarService.showError('Failed to add to wishlist');
      }
    } catch (e) {
      log('Error adding to wishlist: $e');
      emit(state.copyWith(
        isAddingToWishlist: false,
        clearProcessingProductId: true,
        errorMessage: 'Failed to add to wishlist: $e',
      ));

      DependencyInjector().snackBarService.showError('Failed to add to wishlist');
    }
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(String id) async {
    // Check if user is logged in

    // Check if in wishlist
    if (!state.isFavorite(id)) {
      return; // Not in wishlist
    }

    // Set processing state
    emit(state.copyWith(
      isRemovingFromWishlist: true,
      processingProductId: id,
    ));

    try {
      final success = await _wishlistRepository.removeFromFavorites(id);

      if (success) {
        // Update local state immediately for better UX
        final updatedFavoriteIds = List<String>.from(state.favoriteIds)..remove(id);
        final updatedItems = state.items.where((item) => item.id != id).toList();

        emit(state.copyWith(
          favoriteIds: updatedFavoriteIds,
          items: updatedItems,
          isRemovingFromWishlist: false,
          clearProcessingProductId: true,
        ));

        DependencyInjector().snackBarService.showSuccess('Removed from wishlist');
      } else {
        emit(state.copyWith(
          isRemovingFromWishlist: false,
          clearProcessingProductId: true,
          errorMessage: 'Failed to remove from wishlist',
        ));

        DependencyInjector().snackBarService.showError('Failed to remove from wishlist');
      }
    } catch (e) {
      log('Error removing from wishlist: $e');
      emit(state.copyWith(
        isRemovingFromWishlist: false,
        clearProcessingProductId: true,
        errorMessage: 'Failed to remove from wishlist: $e',
      ));

      DependencyInjector().snackBarService.showError('Failed to remove from wishlist');
      if (state.isAddingToWishlist) {
        await removeFromWishlist(id);
      } else {
        await addToWishlist(id);
      }
    }

    // Check if a product is in wishlist
    bool isFavorite(String id) {
      return state.isFavorite(id);
    }

    // Check if a product is being processed
    bool isProcessing(String id) {
      return state.isProcessing(id);
    }
  }
}
