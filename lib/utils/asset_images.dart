import 'package:flutter/material.dart';

class AssetImages {
  // Main assets
  static const String logo = 'assets/images/Credit-Mania.png';
  static const String loadingScreen = 'assets/images/loading_screen.png';
  static const String gameBoard = 'assets/images/game_board.png';
  static const String cardMarket = 'assets/images/card_market.png';
  
  // Placeholder images for cards
  static const String assetCardBack1Star = 'assets/images/asset_card_back_1star.png';
  static const String assetCardBack2Star = 'assets/images/asset_card_back_2star.png';
  static const String assetCardBack3Star = 'assets/images/asset_card_back_3star.png';
  static const String eventCardBack = 'assets/images/event_card_back.png';
  static const String lifeCardBack = 'assets/images/life_card_back.png';
  
  // Placeholder images for specific cards
  static const String bankStocks = 'assets/images/bank_stocks.png';
  static const String luxuryCondo = 'assets/images/luxury_condo.png';
  static const String sportCenter = 'assets/images/sport_center.png';
  static const String gold = 'assets/images/gold.png';
  static const String villa = 'assets/images/villa.png';
  static const String artGallery = 'assets/images/art_gallery.png';
  
  // Background
  static const String backgroundWood = 'assets/images/background_wood.jpg';
  
  // Placeholder method to get asset image or fallback to appropriate card back
  static String getCardImageOrFallback(String imageAsset, int starLevel) {
    // In a real implementation, we would check if the asset exists
    // For now, we'll use a simple approach for the prototype
    if (imageAsset.contains('bank_stocks')) {
      return bankStocks;
    } else if (imageAsset.contains('luxury_condo')) {
      return luxuryCondo;
    } else if (imageAsset.contains('sport_center')) {
      return sportCenter;
    } else if (imageAsset.contains('gold')) {
      return gold;
    } else if (imageAsset.contains('villa')) {
      return villa;
    } else if (imageAsset.contains('art_gallery')) {
      return artGallery;
    }
    
    // Fallback to appropriate card back based on star level
    if (starLevel == 1) {
      return assetCardBack1Star;
    } else if (starLevel == 2) {
      return assetCardBack2Star;
    } else {
      return assetCardBack3Star;
    }
  }
  
  // Placeholder method to get event card image or fallback
  static String getEventCardImageOrFallback(String imageAsset) {
    // In a real implementation, we would check if the asset exists
    return eventCardBack;
  }
  
  // Placeholder method to get life card image or fallback
  static String getLifeCardImageOrFallback(String imageAsset) {
    // In a real implementation, we would check if the asset exists
    return lifeCardBack;
  }
}
