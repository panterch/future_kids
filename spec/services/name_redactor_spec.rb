# frozen_string_literal: true

require 'spec_helper'

describe NameRedactor do
  let(:kid) { create(:kid, name: 'Muster', prename: 'Mira', parent: 'Nicole Muster') }

  describe '#redact' do
    it 'replaces the kid\'s own first name with a unique placeholder' do
      expect(described_class.new(kid).redact('Mira war heute motiviert.'))
        .to eq('[Kind1] war heute motiviert.')
    end

    it 'catches a misspelled first name via fuzzy matching' do
      expect(described_class.new(kid).redact('Miera war heute motiviert.'))
        .to eq('[Kind1] war heute motiviert.')
    end

    it 'catches an initial for a known name' do
      expect(described_class.new(kid).redact('M. war heute motiviert.'))
        .to eq('[Kind1] war heute motiviert.')
    end

    it 'does not treat "z. B." (zum Beispiel) as an initial, even when a real person shares the letter' do
      admin = create(:admin, name: 'Steiner', prename: 'Timon')

      result = described_class.new(kid).redact('Nur wenn es z. B. um die Familie geht.')
      expect(result).to eq('Nur wenn es z. B. um die Familie geht.')
      admin.destroy
    end

    it 'does not treat "i. d. R." as initials' do
      result = described_class.new(kid).redact('Das ist i. d. R. der Fall.')
      expect(result).to eq('Das ist i. d. R. der Fall.')
    end

    it 'does not touch unrelated words' do
      expect(described_class.new(kid).redact('Wir haben heute Bruchrechnen geübt.'))
        .to eq('Wir haben heute Bruchrechnen geübt.')
    end

    it 'redacts the guardian name' do
      expect(described_class.new(kid).redact('Nicole hat angerufen.'))
        .to eq('[ErziehungsberechtigteR1] hat angerufen.')
    end

    it 'redacts both guardians when kids.parent names two people separated by "und"' do
      kid.update!(parent: 'Anna und Peter Muster')

      result = described_class.new(kid).redact('Anna hat angerufen, Peter war auch dabei, Muster wollte das wissen.')
      expect(result).not_to include('Anna')
      expect(result).not_to include('Peter')
      expect(result).not_to include('Muster')
      expect(result).to include('[ErziehungsberechtigteR1]')
    end

    it 'redacts guardians separated by a slash with role annotations in parentheses' do
      kid.update!(name: 'Keller', prename: 'Noah', parent: 'Lisa Beispiel (Mutter) / Tom Beispiel (Vater)')

      result = described_class.new(kid).redact('Lisa rief an, Tom war informiert. Die Mutter kam vorbei.')
      expect(result).not_to include('Lisa')
      expect(result).not_to include('Tom')
      # "Mutter" is a role annotation, not a name, and must not itself become
      # a redaction trigger word (it would falsely flag it elsewhere)
      expect(result).to include('Mutter')
    end

    it 'redacts an initial-only guardian mention like "E. + E. Beispiel"' do
      kid.update!(parent: 'E. + E. Beispiel')

      result = described_class.new(kid).redact('E. hat sich gemeldet. Beispiel war einverstanden.')
      expect(result).not_to include('Beispiel')
      expect(result).to include('[ErziehungsberechtigteR1]')
    end

    it 'rehydrates a guardian placeholder with the original, unparsed field value' do
      kid.update!(parent: 'Anna a Marca de Muster // Beispiel Fritz (wohnt in Musterhausen)')
      redactor = described_class.new(kid)
      redacted = redactor.redact('Beispiel rief an.')
      expect(redactor.rehydrate(redacted)).to eq('Anna a Marca de Muster // Beispiel Fritz (wohnt in Musterhausen) rief an.')
    end

    it 'redacts teachers including the third teacher, with distinct placeholders' do
      teacher = create(:teacher, name: 'Berger', prename: 'Anna')
      third_teacher = create(:teacher, name: 'Keller', prename: 'Tom')
      kid.update!(teacher: teacher, third_teacher: third_teacher)

      result = described_class.new(kid).redact('Anna und Tom waren beide dabei.')
      expect(result).to include('[Lehrperson1]')
      expect(result).to include('[Lehrperson2]')
      expect(result).not_to include('Anna')
      expect(result).not_to include('Tom')
    end

    it 'redacts mentors mentioned only via a journal entry, not the kid\'s current mentor field' do
      old_mentor = create(:mentor, name: 'Fischer', prename: 'Lea')
      create(:journal, kid: kid, mentor: old_mentor)

      expect(described_class.new(kid).redact('Lea hat mit ihr gerechnet.'))
        .to eq('[Mentor1] hat mit ihr gerechnet.')
    end

    it 'redacts admins even when not assigned to this kid' do
      admin = create(:admin, name: 'Wyss', prename: 'Sara')

      expect(described_class.new(kid).redact('Sara war zu Besuch.'))
        .to eq('[Coach1] war zu Besuch.')
    end

    it 'redacts principals of the kid\'s own school but not principals of other schools' do
      school = create(:school)
      other_school = create(:school)
      kid.update!(school: school)
      create(:principal, name: 'Huber', prename: 'Peter', schools: [school])
      create(:principal, name: 'Meier', prename: 'Karin', schools: [other_school])

      result = described_class.new(kid).redact('Peter und Karin kamen vorbei.')
      expect(result).to include('[Schulleitung1]')
      expect(result).to include('Karin')
    end

    it 'assigns the same placeholder to repeated mentions of the same person' do
      result = described_class.new(kid).redact('Mira mag Mira gern.')
      expect(result).to eq('[Kind1] mag [Kind1] gern.')
    end

    it 'redacts every word of a compound multi-word name, not just the words it shares with the guardian' do
      kid.update!(name: 'De La Fuente Muster', prename: 'Sofia Elena', parent: 'Carlos De La Fuente Beispiel')

      result = described_class.new(kid).redact('De La Fuente Muster ist Sofia Elena.')
      expect(result).not_to include('Fuente')
      expect(result).not_to include('Muster')
      expect(result).not_to include('Sofia')
      expect(result).not_to include('Elena')
    end

    it 'collapses immediately-adjacent repeats of the same placeholder' do
      admin = create(:admin, name: 'Wenger', prename: 'Rahel')

      expect(described_class.new(kid).redact('Wenger, Rahel hat angerufen.')).to eq('[Coach1] hat angerufen.')
      expect(described_class.new(kid).redact('Wenger Rahel hat angerufen.')).to eq('[Coach1] hat angerufen.')
      admin.destroy
    end

    it 'does not collapse two separate mentions with a real word between them' do
      result = described_class.new(kid).redact('Mira und nochmals Mira waren da.')
      expect(result).to eq('[Kind1] und nochmals [Kind1] waren da.')
    end
  end

  describe '#placeholder_for_record' do
    it 'returns a deterministic placeholder without any fuzzy text matching' do
      teacher = create(:teacher, name: 'Brunner', prename: 'Timo')
      kid.update!(teacher: teacher)

      expect(described_class.new(kid).placeholder_for_record(teacher)).to eq('[Lehrperson1]')
    end

    it 'returns nil for a nil record' do
      expect(described_class.new(kid).placeholder_for_record(nil)).to be_nil
    end

    it 'still redacts a record that is not part of the pre-built dictionary, as a safety net' do
      other_kid = create(:kid, name: 'Fremd', prename: 'Anderes')

      expect(described_class.new(kid).placeholder_for_record(other_kid)).to eq('[Kind1]')
    end
  end

  describe '#rehydrate' do
    it 'restores the real name for a placeholder produced by redact' do
      redactor = described_class.new(kid)
      redacted = redactor.redact('Mira war heute motiviert.')
      expect(redactor.rehydrate(redacted)).to eq('Mira war heute motiviert.')
    end

    it 'returns text unchanged when no placeholders were ever produced' do
      redactor = described_class.new(kid)
      expect(redactor.rehydrate('Ein normaler Satz.')).to eq('Ein normaler Satz.')
    end
  end
end
