class SalesAnalytics {
  final double totalSales;
  final double salesGrowth;
  final int totalOrders;
  final double ordersGrowth;
  final double averageOrder;
  final double averageOrderGrowth;
  final int totalBookings;
  final double bookingsGrowth;
  final List<SalesTrendData> salesTrend;
  final List<PopularDish> popularDishes;
  final OrderBreakdown orderBreakdown;

  SalesAnalytics({
    required this.totalSales,
    required this.salesGrowth,
    required this.totalOrders,
    required this.ordersGrowth,
    required this.averageOrder,
    required this.averageOrderGrowth,
    required this.totalBookings,
    required this.bookingsGrowth,
    required this.salesTrend,
    required this.popularDishes,
    required this.orderBreakdown,
  });

  factory SalesAnalytics.dummy() {
    return SalesAnalytics(
      totalSales: 14320,
      salesGrowth: 8.2,
      totalOrders: 324,
      ordersGrowth: 5.7,
      averageOrder: 44.20,
      averageOrderGrowth: 2.3,
      totalBookings: 86,
      bookingsGrowth: -3.1,
      salesTrend: [
        SalesTrendData('Mon', 2100),
        SalesTrendData('Tue', 1800),
        SalesTrendData('Wed', 2400),
        SalesTrendData('Thu', 2000),
        SalesTrendData('Fri', 2800),
        SalesTrendData('Sat', 3200),
        SalesTrendData('Sun', 3000),
      ],
      popularDishes: [
        PopularDish('Grilled Salmon', 2600),
        PopularDish('Chicken Parmesan', 1950),
        PopularDish('Beef Burger', 1850),
        PopularDish('Caesar Salad', 1300),
        PopularDish('Spaghetti', 950),
      ],
      orderBreakdown: OrderBreakdown(
        delivery: 45,
        pickup: 30,
        dineIn: 25,
      ),
    );
  }
}

class SalesTrendData {
  final String day;
  final double amount;

  SalesTrendData(this.day, this.amount);
}

class PopularDish {
  final String name;
  final double revenue;

  PopularDish(this.name, this.revenue);
}

class OrderBreakdown {
  final int delivery;
  final int pickup;
  final int dineIn;

  OrderBreakdown({
    required this.delivery,
    required this.pickup,
    required this.dineIn,
  });

  int get total => delivery + pickup + dineIn;
}
