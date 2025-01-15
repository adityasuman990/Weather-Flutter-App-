import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'weather_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 18, color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.white60),
          displayLarge: TextStyle(fontFamily: 'Roboto', fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
        brightness: Brightness.dark,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;

  void _getWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await WeatherService().getWeather(_cityController.text);
      setState(() {
        _weatherData = weather;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching weather data. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getBackgroundColor() {
    if (_weatherData != null) {
      final condition = _weatherData!['weather'][0]['main'];
      switch (condition) {
        case 'Clear':
          return Color(0xFF6FBF73);
        case 'Clouds':
          return Color(0xFF607D8B);
        case 'Rain':
          return Color(0xFFD3D3D3);
        default:
          return Color(0xFF9E9E9E);
      }
    }
    return Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    return Scaffold(
      appBar: AppBar(
        title: Text('Aditya Weather App', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.blueGrey[700],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor.withOpacity(0.8),
              backgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _cityController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  hintStyle: TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.black45,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.all(15),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: _getWeather,
                  ),
                ),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(
                child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
              )
                  : _weatherData == null
                  ? Text('Enter a city to get weather information.', style: TextStyle(color: Colors.white70))
                  : Column(
                children: [
                  Text(
                    '${_weatherData!['main']['temp']}°C',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${_weatherData!['weather'][0]['description']}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 20),
                  Image.network(
                    'https://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  _buildWeatherInfo('Humidity', '${_weatherData!['main']['humidity']}%'),
                  _buildWeatherInfo('Wind Speed', '${_weatherData!['wind']['speed']} m/s'),
                  _buildWeatherInfo('Pressure', '${_weatherData!['main']['pressure']} hPa'),
                  _buildWeatherInfo('Sunrise', _formatTime(_weatherData!['sys']['sunrise'])),
                  _buildWeatherInfo('Sunset', _formatTime(_weatherData!['sys']['sunset'])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildWeatherInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Card(
        color: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$label: ', style: TextStyle(fontSize: 20, color: Colors.white)),
              Text(value, style: TextStyle(fontSize: 20, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
