import 'package:equatable/equatable.dart';

class SymbolModel extends Equatable {
  final String? description;
  final String? displaySymbol;
  final String? symbol;
  final double? price;
  final bool? isPriceIncreasing;

  const SymbolModel({
    this.description,
    this.displaySymbol,
    this.symbol,
    this.price,
    this.isPriceIncreasing,
  });

  factory SymbolModel.fromJson(Map<String, dynamic> json) {
    return SymbolModel(
      description: json['description'],
      displaySymbol: json['displaySymbol'],
      symbol: json['symbol'],
      price: json['price'],
      isPriceIncreasing: json['isPriceIncreasing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'displaySymbol': displaySymbol,
      'symbol': symbol,
      'price': price,
      'isPriceIncreasing': isPriceIncreasing,
    };
  }

  @override
  List<Object?> get props =>
      [description, displaySymbol, symbol, price, isPriceIncreasing];

  SymbolModel copyWith({
    String? description,
    String? displaySymbol,
    String? symbol,
    double? price,
    bool? isPriceIncreasing,
  }) {
    return SymbolModel(
      description: description ?? this.description,
      displaySymbol: displaySymbol ?? this.displaySymbol,
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      isPriceIncreasing: isPriceIncreasing ?? this.isPriceIncreasing,
    );
  }
}
