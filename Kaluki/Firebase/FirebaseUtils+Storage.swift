//
//  FirebaseUtils+Storage.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import FirebaseStorage
import Foundation

extension FirebaseUtils
{
    static let profileImages = storage.child("profileImages")

    static func profileImageRef(playerID id: String) -> StorageReference
    {
        profileImages.child(id + ".jpg")
    }

    static func setProfileImage(profileImage image: UIImage, for playerID: String, completion: ((Bool) -> Void)? = nil)
    {
        let data = image.jpegData(compressionQuality: 0.1)
        let profileImageRef = profileImageRef(playerID: playerID)

        profileImageRef.putData(data!, metadata: nil)
        { metadata, error in
            guard let metadata
            else
            {
                print(error?.localizedDescription ?? "")
                return
            }

            completion?(true)

            self.playerRef(playerID: playerID).setData(["profileImage": metadata.path!], merge: true)
        }

        completion?(false)
    }
}
