using System.Windows.Data;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace XenoUI.Converters
{
    public class WhiteImageConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            if (value is string imagePath)
            {
                var image = new BitmapImage(new Uri(imagePath, UriKind.RelativeOrAbsolute));
                var whiteImage = new FormatConvertedBitmap();
                whiteImage.BeginInit();
                whiteImage.Source = image;
                whiteImage.DestinationFormat = PixelFormats.Gray32Float;
                whiteImage.EndInit();
                return whiteImage;
            }
            return value;
        }

        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
} 