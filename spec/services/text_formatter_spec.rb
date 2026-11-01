# frozen_string_literal: true

require 'spec_helper'

describe TextFormatter do
  def html(text)
    described_class.to_html(text).to_s
  end

  describe 'plain text' do
    it 'renders paragraphs and line breaks like simple_format' do
      expect(html("Erster Satz\nzweite Zeile\n\nNeuer Absatz"))
        .to eq("<p>Erster Satz\n<br />zweite Zeile</p>\n\n<p>Neuer Absatz</p>")
    end

    it 'sanitizes like simple_format' do
      expect(html('Hallo <script>alert(1)</script><b>Welt</b>')).to eq('<p>Hallo alert(1)<b>Welt</b></p>')
    end

    it 'handles windows line endings' do
      expect(html("- Lesen\r\n- Rechnen")).to eq('<ul class="text-list"><li>Lesen</li><li>Rechnen</li></ul>')
    end

    it 'returns an html safe string' do
      expect(described_class.to_html("- Lesen\nText")).to be_html_safe
    end
  end

  describe 'bulleted lists' do
    it 'turns lines starting with a dash into a list' do
      expect(html("- Lesen\n- Rechnen")).to eq('<ul class="text-list"><li>Lesen</li><li>Rechnen</li></ul>')
    end

    it 'does not require a space after the dash' do
      expect(html("-Lesen\n-Rechnen")).to eq('<ul class="text-list"><li>Lesen</li><li>Rechnen</li></ul>')
    end

    it 'accepts bullets pasted from Word, followed by a tab' do
      expect(html("•\tLesen\n·\tRechnen\n▪\tSchreiben"))
        .to eq('<ul class="text-list"><li>Lesen</li><li>Rechnen</li><li>Schreiben</li></ul>')
    end

    it 'accepts an en dash, as typed "- " gets autocorrected to' do
      expect(html('– Lesen')).to eq('<ul class="text-list"><li>Lesen</li></ul>')
    end

    it 'accepts an indented marker' do
      expect(html('   - Lesen')).to eq('<ul class="text-list"><li>Lesen</li></ul>')
    end

    it 'accepts an asterisk followed by a space' do
      expect(html('* Lesen')).to eq('<ul class="text-list"><li>Lesen</li></ul>')
    end

    it 'keeps an asterisk without a space as text, as it is mostly emphasis' do
      expect(html('*Lob* gegeben')).to eq('<p>*Lob* gegeben</p>')
    end

    it 'keeps text before and after the list as paragraphs' do
      expect(html("Wir haben gemacht:\n- Lesen\n- Rechnen\nDanach Pause."))
        .to eq("<p>Wir haben gemacht:</p>\n" \
               "<ul class=\"text-list\"><li>Lesen</li><li>Rechnen</li></ul>\n" \
               '<p>Danach Pause.</p>')
    end

    it 'adds an indented line to the item before it' do
      expect(html("- Rechnen\n  (nur Einmaleins)\n- Lesen"))
        .to eq('<ul class="text-list"><li>Rechnen<br>(nur Einmaleins)</li><li>Lesen</li></ul>')
    end

    it 'keeps an indented line without an item before it as text' do
      expect(html('  eingerückt')).to eq('<p>  eingerückt</p>')
    end

    it 'keeps items separated by blank lines in one list' do
      expect(html("- Lesen\n\n- Rechnen")).to eq('<ul class="text-list"><li>Lesen</li><li>Rechnen</li></ul>')
    end

    it 'ends the list at a blank line followed by text' do
      expect(html("- Lesen\n\nText")).to eq("<ul class=\"text-list\"><li>Lesen</li></ul>\n<p>Text</p>")
    end

    it 'sanitizes the items' do
      expect(html('- <script>x</script><i>Lesen</i>')).to eq('<ul class="text-list"><li>x<i>Lesen</i></li></ul>')
    end
  end

  describe 'numbered lists' do
    it 'turns numbered lines into a list' do
      expect(html("1. Lesen\n2) Rechnen")).to eq('<ol class="text-list"><li>Lesen</li><li>Rechnen</li></ol>')
    end

    it 'keeps the starting number' do
      expect(html("3. Lesen\n4. Rechnen")).to eq('<ol class="text-list" start="3"><li>Lesen</li><li>Rechnen</li></ol>')
    end

    it 'keeps a single numbered line as text' do
      expect(html('3. Treffen im Mai')).to eq('<p>3. Treffen im Mai</p>')
    end

    it 'requires a space after the number, so decimals and dates stay text' do
      expect(html("1.5h im Zimmer\n12.3.2024 Ausflug")).to eq("<p>1.5h im Zimmer\n<br />12.3.2024 Ausflug</p>")
    end

    it 'starts a new list when the kind changes' do
      expect(html("- Lesen\n1. Rechnen\n2. Schreiben"))
        .to eq("<ul class=\"text-list\"><li>Lesen</li></ul>\n" \
               '<ol class="text-list"><li>Rechnen</li><li>Schreiben</li></ol>')
    end
  end

  describe 'bare markers and separators' do
    it 'keeps a bare dash meaning "nothing to report" as text' do
      expect(html("Schwierigkeiten:\n-")).to eq("<p>Schwierigkeiten:\n<br />-</p>")
    end

    it 'drops bare markers inside and around a list as empty items' do
      expect(html("-\n- Lesen\n-\n- Rechnen\n-")).to eq('<ul class="text-list"><li>Lesen</li><li>Rechnen</li></ul>')
    end

    it 'keeps separator lines as text' do
      expect(html("Teil 1\n---\n***\n______\nTeil 2"))
        .to eq("<p>Teil 1\n<br />---\n<br />***\n<br />______\n<br />Teil 2</p>")
    end

    it 'keeps underscores used as blanks as text' do
      expect(html('430 + _ = 880 oder 610 - 180 = _')).to eq('<p>430 + _ = 880 oder 610 - 180 = _</p>')
    end
  end

  describe 'arrows' do
    it 'turns typed arrows into arrow characters' do
      expect(html('a -> b --> c <- d <-- e <-> f => g')).to eq('<p>a → b → c ← d ← e ↔ f ⇒ g</p>')
    end

    it 'keeps a line starting with an arrow as text, not a list item' do
      expect(html("- Lesen\n-> Überraschung"))
        .to eq("<ul class=\"text-list\"><li>Lesen</li></ul>\n<p>→ Überraschung</p>")
    end

    it 'converts arrows inside list items' do
      expect(html('- Lesen -> gut')).to eq('<ul class="text-list"><li>Lesen → gut</li></ul>')
    end
  end
end
