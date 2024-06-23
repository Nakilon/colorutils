module ColorUtils

  def self.rgb2hsv r, g, b
    # in: [<256, <256, <256]
    # http://stackoverflow.com/q/41926874/322020
    r, g, b  = [r, g, b].map{ |_| _.fdiv 255 }
    min, max = [r, g, b].minmax
    chroma   = max - min
    [
      60.0 * ( chroma.zero? ? 0 : case max
        when r ; (g - b) / chroma
        when g ; (b - r) / chroma + 2
        when b ; (r - g) / chroma + 4
        else 0
      end % 6 ),
      chroma.zero? ? 0.0 : chroma / max,
      max,
    ]   # [<=360, <=1, <=1]
  end
  def self.hsv2rgb h, s, v
    # in: [<360 (floor), <100, <100]
    # out: [<256, <256, <256]
    vmin = (100 - s) * v / 100
    a = (v - vmin) * (h % 60) / 60.0
    vinc = vmin + a
    vdec = v - a
    case h / 60
    when 0 ; [v, vinc, vmin]
    when 1 ; [vdec, v, vmin]
    when 2 ; [vmin, v, vinc]
    when 3 ; [vmin, vdec, v]
    when 4 ; [vinc, vmin, v]
    when 5 ; [v, vmin, vdec]
    else ; fail "bad hue value: #{h}"
    end.map{ |i| (2.55 * i).round }
  end

  def self.dist h1, s1, v1, h2, s2, v2
    # in: [<256, <256, <256]
    # https://en.wikipedia.org/wiki/HSL_and_HSV#/media/File:Hsl-hsv_saturation-lightness_slices.svg
    # optimized
    c1, c2 = s1 * v1 / 256.0, s2 * v2 / 256.0   # chroma
    z1, z2 = v1 * (2 - c1 / 256), v2 * (2 - c2 / 256)
    a = (((h2 - h1) * 360 / 256.0) % 360) / (180 / Math::PI)
        x2 =     Math::sin(a) * c2
    y1, y2 = c1, Math::cos(a) * c2
    x2*x2 + (y1-y2)*(y1-y2) + (z1-z2)*(z1-z2)
  end

  def self.golden_hue
    # https://en.wikipedia.org/wiki/Golden_angle
    # https://www.wolframalpha.com/input?i=y%3Dax%5E4%2Bbx%5E3%2Bcx%5E2%2Bdx%2C+1%3Da%2Bb%2Bc%2Bd%2C+c%3D4a%2B3b%2B2c%2Bd%2C+1.2%3D4a%281%2F3%29%5E3%2B3b%281%2F3%29%5E2%2B2c%281%2F3%29%2Bd%2C+0.8%3D4a%282%2F3%29%5E3%2B3b%282%2F3%29%5E2%2B2c%282%2F3%29%2Bd%2C+a%3D%3F%2C+b%3D%3F%2C+c%3D%3F%2C+d%3D%3F
    ::Enumerator.new do |e|
      a = 0.0
      loop do
        t = a % 1
        e << ::Math::PI * 2 * (t*t*t*t - t*t*t*2 + t*t*38/45 + t*52/45)
        a += (3 - ::Math::sqrt(5)) / 2.0
      end
    end
  end
end
