import SwiftUI

struct DosageSectionView: View {
    var title: String
    @Binding var dosage: Dosage?
    @State private var amount: String = ""
    @State private var unit: DosageUnit = .mg

    init(title: String, dosage: Binding<Dosage?>) {
        self.title = title
        _dosage = dosage

        if let dosage = dosage.wrappedValue {
            _amount = State(initialValue: dosage.amount)
            _unit = State(initialValue: dosage.unit)
        }
    }

    var body: some View {
        Section(title) {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            Picker("Unit", selection: $unit) {
                ForEach(DosageUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .onChange(of: amount) {
                self.updateDosage()
            }
            .onChange(of: unit) {
                self.updateDosage()
            }
        }
    }

    private func updateDosage() {
        if amount.isEmpty {
            _dosage.wrappedValue = nil
            return
        }
        _dosage.wrappedValue = Dosage(amount: amount, unit: unit)
    }
}

#Preview {
    @Previewable @State var dosage: Dosage?
    DosageSectionView(title: "Dosage", dosage: $dosage)
}
