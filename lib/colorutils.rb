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
    ::Enumerator.new do |e|
      a = 0
      loop do
        e << a
        a += ::Math::PI * (3 - ::Math::sqrt(5))
        a %= ::Math::PI * 2
      end
    end
  end
end
