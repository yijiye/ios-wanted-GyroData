//
//  MeasureGyroDataViewController.swift
//  GyroData
//
//  Created by 리지 on 2023/06/13.
//

import UIKit
import Combine

final class MeasureGyroDataViewController: UIViewController {
    
    private let viewModel: MeasureViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var threeAxisData: [ThreeAxisValue]?
    
    private var totalTime: Double = 00.0
    private var selectedSensor: SensorType = .accelerometer
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Acc", "Gyro"])
        
        return control
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
       let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = .systemGray
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        let lineWidth: CGFloat = 3
        view.layer.borderWidth = lineWidth
        
        return view
    }()
    
    private lazy var graphView: GraphView = {
        let view = GraphView(frame: .zero, viewModel: nil)
        
        return view
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        
        return stackView
    }()
    
    private let measurementButton: UIButton = {
        let button = UIButton()
        let title = "측정"
        let fontSize: CGFloat = 25
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        
        return button
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton()
        let title = "정지"
        let fontSize: CGFloat = 25
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        
        return button
    }()

    init(viewModel: MeasureViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        bind()
    }
    
    private func bind() {
        viewModel.accelerometerSubject
            .sink { [weak self] data, time in
                self?.threeAxisData = data
                self?.totalTime = time
                self?.graphView.drawGraph(with: data)
            }
            .store(in: &cancellables)
        viewModel.gyroscopeSubject
            .sink { [weak self] data, time in
                self?.threeAxisData = data
                self?.totalTime = time
                self?.graphView.drawGraph(with: data)
            }
            .store(in: &cancellables)
    }
    
    private func setUpView() {
        setUpNavigationBar()
        
        view.backgroundColor = .white
        setUpUI()
        setUpActivityIndicator()
        setUpSegmentedControl()
        setUpButtons()
    }
    
    private func setUpNavigationBar() {
        let title = "측정하기"
        let save = "저장"
        let rightButtonItem = UIBarButtonItem(title: save,
                                              style: .plain,
                                              target: self,
                                              action: #selector(saveButtonTapped))
        navigationItem.title = title
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.rightBarButtonItem = rightButtonItem
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func setUpActivityIndicator() {
        view.addSubview(activityIndicator)
        
        let safeArea = view.safeAreaLayoutGuide
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: safeArea.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            ])
    }
    
    private func setUpSegmentedControl() {
        let fontSize: CGFloat = 20
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemTeal
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: UIColor.darkGray
            ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: UIColor.white
            ]
        
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        segmentedControl.addTarget(self, action: #selector(changeSensorType), for: .valueChanged)
    }
    
    private func setUpUI() {
        view.addSubview(segmentedControl)
        view.addSubview(borderView)
        view.addSubview(labelStackView)
        borderView.addSubview(graphView)
        labelStackView.addArrangedSubview(measurementButton)
        labelStackView.addArrangedSubview(stopButton)

        let safeArea = view.safeAreaLayoutGuide
        let segmentControlTop: CGFloat = 10
        let leading: CGFloat = 30
        let trailing: CGFloat = -30
        let contentsTop: CGFloat = 20
        let bottom: CGFloat = -140
        let graphViewAllConstant: CGFloat = 5
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        graphView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: segmentControlTop),
            segmentedControl.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: leading),
            segmentedControl.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: trailing),
            
            borderView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: contentsTop),
            borderView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            borderView.widthAnchor.constraint(equalTo: borderView.heightAnchor),
            
            graphView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: graphViewAllConstant),
            graphView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: graphViewAllConstant),
            graphView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: graphViewAllConstant * -1),
            graphView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: graphViewAllConstant * -1),
            
            labelStackView.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: contentsTop),
            labelStackView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: bottom)
        ])
    }
    
    private func setUpButtons() {
        measurementButton.addTarget(self, action: #selector(startMeasure), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopMeasure), for: .touchUpInside)
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let okSign = "확인"
        AlertBuilder(viewController: self)
            .withTitle(title)
            .andMessage(message)
            .preferredStyle(.alert)
            .onSuccessAction(title: okSign) { _ in }
            .showAlert()
    }
}

// MARK: Button Action
extension MeasureGyroDataViewController {
    @objc private func changeSensorType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSensor = .accelerometer
        case 1:
            selectedSensor = .gyroscope
        default:
            return
        }
    }
    
    @objc private func startMeasure() {
        let title = "측정을 시작했습니다!"
        let message = "측정이 완료되면 버튼이 활성화됩니다. \n 잠시만 기다려주세요."
        showAlert(title, message)
        viewModel.startMeasure(by: selectedSensor)
        bindIsProcessing()
    }
    
    @objc private func stopMeasure() {
        viewModel.stopMeasure()
        bindIsProcessing()
    }
    
    private func bindIsProcessing() {
        viewModel.isProcessingSubject
            .sink { [weak self] bool in
                if bool == true {
                    self?.segmentedControl.isEnabled = false
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                } else if bool == false {
                    self?.segmentedControl.isEnabled = true
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func saveButtonTapped() {
        bindIsSaving()
        if let threeAxisData = threeAxisData {
            let data = SixAxisDataForJSON(id: UUID(), date: Date(), title: selectedSensor.description, threeAxisValue: threeAxisData)
            viewModel.saveToFileManager(data, time: totalTime)
            bindIsSaveFailure()
        } else {
            let title = "측정된 데이터가 없습니다."
            let message = "다시 확인해주세요."
            showAlert(title, message)
        }
    }
    
    private func bindIsSaving() {
        viewModel.isSavingSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                if bool == true {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindIsSaveFailure() {
        viewModel.isSaveFailed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool, error in
                if bool == true {
                    let title = "\(error)로 인해 저장을 실패하였습니다."
                    let message = "다시 확인해주세요."
                    self?.showAlert(title, message)
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
}
