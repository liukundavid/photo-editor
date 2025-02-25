//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public final class PhotoEditorViewController: UIViewController {
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet var canvasView: UIView!
    // To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    // To hold the drawings and stickers
    @IBOutlet var canvasImageView: UIImageView!

    @IBOutlet var topToolbar: UIView!
    @IBOutlet var bottomToolbar: UIView!
    @IBOutlet var textAdjustToolbar: UIView!

    @IBOutlet var topGradient: UIView!
    @IBOutlet var bottomGradient: UIView!

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var deleteView: UIView!
    @IBOutlet var colorsCollectionView: UICollectionView!
    @IBOutlet var colorPickerView: UIView!
    @IBOutlet var colorPickerViewBottomConstraint: NSLayoutConstraint!

    // Controls
    @IBOutlet var cropButton: UIButton!
    @IBOutlet var stickerButton: UIButton!
    @IBOutlet var drawButton: UIButton!
    @IBOutlet var textButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var clearButton: UIButton!

    @IBOutlet var fontSizeIncreaseButton: UIButton!
    @IBOutlet var fontSizeDecreaseButton: UIButton!
    @IBOutlet var textBackgroundColorButton: UIButton!
    @IBOutlet var fontSizeDoneButton: UIButton!

    public var image: UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers: [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors: [UIColor] = []

    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!

    // list of controls to be hidden
    public var hiddenControls: [control] = []

    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var textFont: UIFont = UIFont(name: "Helvetica", size: 30)!
    var isDrawing: Bool = false
    var isSettingTextBackground: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont: UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isEditText: Bool = false
    var isTyping: Bool = false

    var stickersViewController: StickersViewController!

    // Register Custom font before we load XIB
    override public func loadView() {
        registerFont()
        super.loadView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setImageView(image: image!)

        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        hideControls()
    }

    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate

        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }

    func setImageView(image: UIImage) {
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
    }

    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        bottomGradient.isHidden = hide
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            drawColor = color
        } else if activeTextView != nil {
            if isSettingTextBackground {
                activeTextView?.backgroundColor = color
                if let textView = activeTextView {
                    updateTextSize(textView)
                }
            } else {
                activeTextView?.textColor = color
                textColor = color
            }
        }
    }

    func didSelectTextBackground(on: Bool) {
        isSettingTextBackground = on
    }
}
