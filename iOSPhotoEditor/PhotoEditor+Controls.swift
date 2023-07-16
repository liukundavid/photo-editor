//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - Control

public enum control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

extension PhotoEditorViewController {
    // MARK: Top Toolbar

    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonTapped(_ sender: UIButton) {
        let controller = CropViewController()
        controller.delegate = self
        controller.view.backgroundColor = .black
        controller.image = self.image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    @IBAction func stickersButtonTapped(_ sender: Any) {
        addStickersViewController()
    }

    @IBAction func drawButtonTapped(_ sender: Any) {
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        hideToolbar(hide: true)
    }

    @IBAction func textButtonTapped(_ sender: Any) {
        isTyping = true
        hideToolbar(hide: true)
        textAdjustToolbar.isHidden = false
        colorPickerView.isHidden = false

        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))

        textView.textAlignment = .center
        textView.font = textFont
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        hideToolbar(hide: false)
        isDrawing = false
    }

    // MARK: Font Toolbar

    @IBAction func textFontIncreaseButtonTapped(_ sender: Any) {
        if let textView = activeTextView {
            if textView.font!.pointSize < 90 {
                let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize + 2.0)
                textView.font = font
                lastTextViewFont = font
                let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                             height: CGFloat.greatestFiniteMagnitude))
                textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                              height: sizeToFit.height)
            } else {
                let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                             height: CGFloat.greatestFiniteMagnitude))
                textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                              height: sizeToFit.height)
            }

            textView.setNeedsDisplay()
        }
    }

    @IBAction func textFontDecreaseButtonTapped(_ sender: Any) {
        if let textView = activeTextView {
            if textView.font!.pointSize > 10 {
                let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize - 2.0)
                textView.font = font
                lastTextViewFont = font
                let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                             height: CGFloat.greatestFiniteMagnitude))
                textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                              height: sizeToFit.height)
            } else {
                let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                             height: CGFloat.leastNormalMagnitude))
                textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                              height: sizeToFit.height)
            }

            textView.setNeedsDisplay()
        }
    }

    @IBAction func textBackgroundColorButtonTapped(_ sender: Any) {
        textBackgroundColorButton.isSelected = !textBackgroundColorButton.isSelected
        isSettingTextBackground = textBackgroundColorButton.isSelected
    }

    @IBAction func textAdjustDoneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        textAdjustToolbar.isHidden = true
        colorPickerView.isHidden = true
        hideToolbar(hide: false)
    }

    // MARK: Bottom Toolbar

    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(), self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        // clear drawing
        canvasImageView.image = nil
        // clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }

    @IBAction func continueButtonPressed(_ sender: Any) {
        let img = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: img)
        self.dismiss(animated: true, completion: nil)
    }

    // MAKR: helper methods

    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func hideControls() {
        for control in hiddenControls {
            switch control {
            case .clear:
                clearButton.isHidden = true
            case .crop:
                cropButton.isHidden = true
            case .draw:
                drawButton.isHidden = true
            case .save:
                saveButton.isHidden = true
            case .share:
                shareButton.isHidden = true
            case .sticker:
                stickerButton.isHidden = true
            case .text:
                stickerButton.isHidden = true
            }
        }
    }
}
