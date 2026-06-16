import SwiftUI
import SwiftData
import UIKit

struct PetCreateScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var existingPet: Pet? = nil

    @State private var name = ""
    @State private var species: Species = .dog
    @State private var breed = ""
    @State private var birthDate = Date()
    @State private var chipNumber = ""
    @State private var avatarImage: UIImage?
    @State private var avatarRemoved = false
    @State private var showImagePicker = false
    @State private var imagePickerSource: ImagePicker.Source = .photoLibrary
    @State private var saveError: String?

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                    PetAvatarPicker(
                        species: species,
                        image: avatarImage,
                        onPickCamera: {
                            imagePickerSource = .camera
                            showImagePicker = true
                        },
                        onPickLibrary: {
                            imagePickerSource = .photoLibrary
                            showImagePicker = true
                        },
                        onRemove: {
                            avatarImage = nil
                            avatarRemoved = true
                        }
                    )

                    AppFormSection(title: "Basics", subtitle: "Identity and species") {
                        AppFormTextField(label: "Name", text: $name, placeholder: "Luna")
                        AppFormPicker(label: "Species", selection: $species) {
                            ForEach(Species.allCases) { s in
                                Label(s.label, systemImage: "pawprint").tag(s)
                            }
                        }
                        AppFormTextField(label: "Breed", text: $breed, placeholder: "Golden Retriever")
                    }

                    AppFormSection(title: "Details", subtitle: "Age and identification") {
                        AppFormDatePicker(label: "Birth Date", date: $birthDate, maxDate: Date())
                        AppFormTextField(
                            label: "Microchip Number",
                            text: $chipNumber,
                            placeholder: "Optional",
                            keyboardType: .numberPad
                        )
                    }

                    LegalFootnote(compact: true)

                    Button(action: save) {
                        Text(existingPet == nil ? "Add Pet" : "Save Changes")
                    }
                    .buttonStyle(AppPrimaryButtonStyle())
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                }
                .padding(AppTheme.spacingMD)
            }
            .appScreen()
            .navigationTitle(existingPet == nil ? "New Pet" : "Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appBrand)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    source: imagePickerSource,
                    onImagePicked: { image in
                        avatarImage = image
                        avatarRemoved = false
                        showImagePicker = false
                    },
                    onCancel: { showImagePicker = false }
                )
                .ignoresSafeArea()
            }
            .alert("Could not save", isPresented: .constant(saveError != nil)) {
                Button("OK") { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
            .task { loadExistingPet() }
        }
    }

    private func loadExistingPet() {
        guard let p = existingPet else { return }
        name = p.name
        species = p.species
        breed = p.breed
        birthDate = p.birthDate
        chipNumber = p.chipNumber ?? ""
        avatarImage = PetAvatarService.image(for: p.passportPhotoFilename)
    }

    private func save() {
        let chip = chipNumber.trimmingCharacters(in: .whitespaces).isEmpty ? nil : chipNumber
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        do {
            if let pet = existingPet {
                pet.name = trimmedName
                pet.species = species
                pet.breed = breed
                pet.birthDate = birthDate
                pet.chipNumber = chip
                try applyAvatar(to: pet)
                try context.save()
            } else {
                let pet = Pet(
                    name: trimmedName,
                    species: species,
                    breed: breed,
                    birthDate: birthDate,
                    chipNumber: chip
                )
                context.insert(pet)
                try context.save()
                try applyAvatar(to: pet)
                try context.save()
            }
            Haptic.success()
            dismiss()
        } catch {
            Haptic.error()
            saveError = error.localizedDescription
        }
    }

    private func applyAvatar(to pet: Pet) throws {
        if avatarRemoved {
            PetAvatarService.delete(filename: pet.passportPhotoFilename)
            pet.passportPhotoFilename = nil
            return
        }
        guard let avatarImage else { return }
        pet.passportPhotoFilename = try PetAvatarService.save(
            image: avatarImage,
            petID: pet.id,
            existingFilename: pet.passportPhotoFilename
        )
    }
}
