import SwiftUI

struct NoteLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var content = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextField("Write your note here…", text: $content, axis: .vertical)
                        .lineLimit(6...)
                        .frame(minHeight: 120, alignment: .topLeading)
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                let note = Note(content: content)
                viewModel.addNote(note)
                dismiss()
            }
            .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

// MARK: - Preview

#Preview {
    NoteLogView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(ModelContainer.preview)
}

