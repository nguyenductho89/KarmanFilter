import CoreLocation
import UIKit
// Define a struct to represent a 1D Kalman filter
import Foundation

/**
 Conventional Kalman Filter
 */
//
//  Matrix.swift
//  KalmanFilterTest
//
//  Created by Oleksii on 20/06/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//
//
//  DoubleExtension.swift
//  KalmanFilterTest
//
//  Created by Oleksii on 20/06/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import Foundation

// MARK: Double as Kalman input
extension Double: KalmanInput {
    public var transposed: Double {
        return self
    }
    
    public var inversed: Double {
        return 1 / self
    }
    
    public var additionToUnit: Double {
        return 1 - self
    }
}

import Foundation
import Accelerate

public struct Matrix: Equatable {
    // MARK: - Properties
    public let rows: Int, columns: Int
    public var grid: [Double]
    
    var isSquare: Bool {
        return rows == columns
    }
    
    // MARK: - Initialization
    
    /**
     Initialization of matrix with rows * columns
     size where all the elements are set to 0.0
     
     - parameter rows: number of rows in matrix
     - parameter columns: number of columns in matrix
     */
    public init(rows: Int, columns: Int) {
        let grid = Array(repeating: 0.0, count: rows * columns)
        self.init(grid: grid, rows: rows, columns: columns)
    }
    
    /**
     Initialization with grid that contains all the
     elements of matrix with given matrix size
     
     - parameter grid: array of matrix elements. **warning**
     Should be of rows * column size.
     - parameter rows: number of rows in matrix
     - parameter columns: number of columns in matrix
     */
    public init(grid: [Double], rows: Int, columns: Int) {
        assert(rows * columns == grid.count, "grid size should be rows * column size")
        self.rows = rows
        self.columns = columns
        self.grid = grid
    }
    
    /**
     Initialization of
     [column vector](https://en.wikipedia.org/wiki/Row_and_column_vectors)
     with given array. Number of
     elements in array equals to number of rows in vector.
     
     - parameter vector: array with elements of vector
     */
    public init(vector: [Double]) {
        self.init(grid: vector, rows: vector.count, columns: 1)
    }
    
    /**
     Initialization of
     [column vector](https://en.wikipedia.org/wiki/Row_and_column_vectors)
     with given number of rows. Every element is assign to 0.0
     
     - parameter size: vector size
     */
    public init(vectorOf size: Int) {
        self.init(rows: size, columns: 1)
    }
    
    /**
     Initialization of square matrix with given size. Number of
     elements in array equals to size * size. Every elements is
     assigned to 0.0
     
     - parameter size: number of rows and columns in matrix
     */
    public init(squareOfSize size: Int) {
        self.init(rows: size, columns: size)
    }
    
    /**
     Initialization of
     [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix)
     of given sizen
     
     - parameter size: number of rows and columns in identity matrix
     */
    public init(identityOfSize size: Int) {
        self.init(squareOfSize: size)
        for i in 0..<size {
            self[i, i] = 1
        }
    }
    
    /**
     Convenience initialization from 2D array
     
     - parameter array2d: 2D array representation of matrix
     */
    public init(_ array2d: [[Double]]) {
        self.init(grid: array2d.flatMap({$0}), rows: array2d.count, columns: array2d.first?.count ?? 0)
    }
    
    // MARK: - Public Methods
    /**
     Determines whether element exists at specified row and
     column
     
     - parameter row: row index of element
     - parameter column: column index of element
     - returns: bool indicating whether spicified indeces are valid
     */
    public func indexIsValid(forRow row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(forRow: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(forRow: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

// MARK: - Equatable

public func == (lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
}

// MARK: -  Matrix as KalmanInput
extension Matrix: KalmanInput {
    /**
     [Transposed](https://en.wikipedia.org/wiki/Transpose)
     version of matrix
     
     Compexity: O(n^2)
     */
    public var transposed: Matrix {
        var resultMatrix = Matrix(rows: columns, columns: rows)
        let columnLength = resultMatrix.columns
        let rowLength = resultMatrix.rows
        grid.withUnsafeBufferPointer { xp in
            resultMatrix.grid.withUnsafeMutableBufferPointer { rp in
                vDSP_mtransD(xp.baseAddress!, 1, rp.baseAddress!, 1, vDSP_Length(rowLength), vDSP_Length(columnLength))
            }
        }
        return resultMatrix
    }
    
    /**
     Addition to Unit in form: **I - A**
     where **I** - is
     [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix)
     and **A** - is self
     
     **warning** Only for square matrices
     
     Complexity: O(n ^ 2)
     */
    public var additionToUnit: Matrix {
        assert(isSquare, "Matrix should be square")
        return Matrix(identityOfSize: rows) - self
    }
    
    /**
     Inversed matrix if
     [it is invertible](https://en.wikipedia.org/wiki/Invertible_matrix)
     */
    public var inversed: Matrix {
        assert(isSquare, "Matrix should be square")
        
        if rows == 1 {
            return Matrix(grid: [1/self[0, 0]], rows: 1, columns: 1)
        }
        
        var inMatrix:[Double] = grid
        // Get the dimensions of the matrix. An NxN matrix has N^2
        // elements, so sqrt( N^2 ) will return N, the dimension
        var N:__CLPK_integer = __CLPK_integer(sqrt(Double(grid.count)))
        var N2:__CLPK_integer = N
        var N3:__CLPK_integer = N
        var lwork = __CLPK_integer(grid.count)
        // Initialize some arrays for the dgetrf_(), and dgetri_() functions
        var pivots:[__CLPK_integer] = [__CLPK_integer](repeating: 0, count: grid.count)
        var workspace:[Double] = [Double](repeating: 0.0, count: grid.count)
        var error: __CLPK_integer = 0
        
        // Perform LU factorization
        dgetrf_(&N, &N2, &inMatrix, &N3, &pivots, &error)
        // Calculate inverse from LU factorization
        dgetri_(&N, &inMatrix, &N2, &pivots, &workspace, &lwork, &error)
        
        if error != 0 {
            assertionFailure("Matrix Inversion Failure")
        }
        return Matrix.init(grid: inMatrix, rows: rows, columns: rows)
    }
    
    /**
     [Matrix determinant](https://en.wikipedia.org/wiki/Determinant)
     */
    public var determinant: Double {
        assert(isSquare, "Matrix should be square")
        var result = 0.0
        if rows == 1 {
            result = self[0, 0]
        } else {
            for i in 0..<rows {
                let sign = i % 2 == 0 ? 1.0 : -1.0
                result += sign * self[i, 0] * additionalMatrix(row: i, column: 0).determinant
            }
        }
        return result
    }
    
    public func additionalMatrix(row: Int, column: Int) -> Matrix {
        assert(indexIsValid(forRow: row, column: column), "Invalid arguments")
        var resultMatrix = Matrix(rows: rows - 1, columns: columns - 1)
        for i in 0..<rows {
            if i == row {
                continue
            }
            for j in 0..<columns {
                if j == column {
                    continue
                }
                let resI = i < row ? i : i - 1
                let resJ = j < column ? j : j - 1
                resultMatrix[resI, resJ] = self[i, j]
            }
        }
        return resultMatrix
    }
    
    // MARK: - Private methods
    fileprivate func operate(with otherMatrix: Matrix, closure: (Double, Double) -> Double) -> Matrix {
        assert(rows == otherMatrix.rows && columns == otherMatrix.columns, "Matrices should be of equal size")
        var resultMatrix = Matrix(rows: rows, columns: columns)
        
        for i in 0..<rows {
            for j in 0..<columns {
                resultMatrix[i, j] = closure(self[i, j], otherMatrix[i, j])
            }
        }
        
        return resultMatrix
    }
}

/**
 Naive add matrices
 
 Complexity: O(n^2)
 */
public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.rows == rhs.rows && lhs.columns == rhs.columns, "Matrices should be of equal size")
    var resultMatrix = Matrix(rows: lhs.rows, columns: lhs.columns)
    vDSP_vaddD(lhs.grid, vDSP_Stride(1), rhs.grid, vDSP_Stride(1), &resultMatrix.grid, vDSP_Stride(1), vDSP_Length(lhs.rows * lhs.columns))
    return resultMatrix
}

/**
 Naive subtract matrices
 
 Complexity: O(n^2)
 */
public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.rows == rhs.rows && lhs.columns == rhs.columns, "Matrices should be of equal size")
    var resultMatrix = Matrix(rows: lhs.rows, columns: lhs.columns)
    vDSP_vsubD(rhs.grid, vDSP_Stride(1), lhs.grid, vDSP_Stride(1), &resultMatrix.grid, vDSP_Stride(1), vDSP_Length(lhs.rows * lhs.columns))
    return resultMatrix
}


/**
 Naive matrices multiplication
 
 Complexity: O(n^3)
 */
public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.rows, "Left matrix columns should be the size of right matrix's rows")
    var resultMatrix = Matrix(rows: lhs.rows, columns: rhs.columns)
    let order = CblasRowMajor
    let atrans = CblasNoTrans
    let btrans = CblasNoTrans
    let α = 1.0
    let β = 1.0
    let resultColumns = resultMatrix.columns
    lhs.grid.withUnsafeBufferPointer { pa in
        rhs.grid.withUnsafeBufferPointer { pb in
            resultMatrix.grid.withUnsafeMutableBufferPointer { pc in
                cblas_dgemm(order, atrans, btrans, Int32(lhs.rows), Int32(rhs.columns), Int32(lhs.columns), α, pa.baseAddress!, Int32(lhs.columns), pb.baseAddress!, Int32(rhs.columns), β, pc.baseAddress!, Int32(resultColumns))
            }
        }
    }
    
    return resultMatrix
}

// MARK: - Nice additional methods
public func * (lhs: Matrix, rhs: Double) -> Matrix {
    return Matrix(grid: lhs.grid.map({ $0*rhs }), rows: lhs.rows, columns: lhs.columns)
}

public func * (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs * lhs
}

// MARK: - CustomStringConvertible for debug output
extension Matrix: CustomStringConvertible {
    public var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = (0..<columns).map{"\(self[i, $0])"}.joined(separator: "\t")
            
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}
public protocol KalmanInput {
    var transposed: Self { get }
    var inversed: Self { get }
    var additionToUnit: Self { get }
    
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
}

public protocol KalmanFilterType {
    associatedtype Input: KalmanInput
    
    var stateEstimatePrior: Input { get }
    var errorCovariancePrior: Input { get }
    
    func predict(stateTransitionModel: Input, controlInputModel: Input, controlVector: Input, covarianceOfProcessNoise: Input) -> Self
    func update(measurement: Input, observationModel: Input, covarienceOfObservationNoise: Input) -> Self
}
public struct KalmanFilter<Type: KalmanInput>: KalmanFilterType {
    /// x̂_k|k-1
    public let stateEstimatePrior: Type
    /// P_k|k-1
    public let errorCovariancePrior: Type
    
    public init(stateEstimatePrior: Type, errorCovariancePrior: Type) {
        self.stateEstimatePrior = stateEstimatePrior
        self.errorCovariancePrior = errorCovariancePrior
    }
    
    /**
     Predict step in Kalman filter.
     
     - parameter stateTransitionModel: F_k
     - parameter controlInputModel: B_k
     - parameter controlVector: u_k
     - parameter covarianceOfProcessNoise: Q_k
     
     - returns: Another instance of Kalman filter with predicted x̂_k and P_k
     */
    public func predict(stateTransitionModel: Type, controlInputModel: Type, controlVector: Type, covarianceOfProcessNoise: Type) -> KalmanFilter {
        // x̂_k|k-1 = F_k * x̂_k-1|k-1 + B_k * u_k
        let predictedStateEstimate = stateTransitionModel * stateEstimatePrior + controlInputModel * controlVector
        // P_k|k-1 = F_k * P_k-1|k-1 * F_k^t + Q_k
        let predictedEstimateCovariance = stateTransitionModel * errorCovariancePrior * stateTransitionModel.transposed + covarianceOfProcessNoise
        
        return KalmanFilter(stateEstimatePrior: predictedStateEstimate, errorCovariancePrior: predictedEstimateCovariance)
    }
    
    /**
     Update step in Kalman filter. We update our prediction with the measurements that we make
     
     - parameter measurement: z_k
     - parameter observationModel: H_k
     - parameter covarienceOfObservationNoise: R_k
     
     - returns: Updated with the measurements version of Kalman filter with new x̂_k and P_k
     */
    public func update(measurement: Type, observationModel: Type, covarienceOfObservationNoise: Type) -> KalmanFilter {
        // H_k^t transposed. We cache it improve performance
        let observationModelTransposed = observationModel.transposed
        
        // ỹ_k = z_k - H_k * x̂_k|k-1
        let measurementResidual = measurement - observationModel * stateEstimatePrior
        // S_k = H_k * P_k|k-1 * H_k^t + R_k
        let residualCovariance = observationModel * errorCovariancePrior * observationModelTransposed + covarienceOfObservationNoise
        // K_k = P_k|k-1 * H_k^t * S_k^-1
        let kalmanGain = errorCovariancePrior * observationModelTransposed * residualCovariance.inversed
        
        // x̂_k|k = x̂_k|k-1 + K_k * ỹ_k
        let posterioriStateEstimate = stateEstimatePrior + kalmanGain * measurementResidual
        // P_k|k = (I - K_k * H_k) * P_k|k-1
        let posterioriEstimateCovariance = (kalmanGain * observationModel).additionToUnit * errorCovariancePrior
        
        return KalmanFilter(stateEstimatePrior: posterioriStateEstimate, errorCovariancePrior: posterioriEstimateCovariance)
    }
}

import CoreLocation
import DGCharts

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
  //  let measurements = [0.39, 0.50, 0.48, 0.29, -1.0, 0.25, 0.32, 0.34, 0.48, 0.41, -1.0, 0.45, 0.46, 0.59, 0.42]
    var measurements: [Double] = []
    var lineChartView: LineChartView!
    var entries: [ChartDataEntry] = []
    var entries2: [ChartDataEntry] = []
    let positionLbl = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 400)))
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(positionLbl)
        positionLbl.backgroundColor = .systemGreen
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: UUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!))
        let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateRSSIValues), userInfo: nil, repeats: true)
        timer.fire() // Fire the timer immediately to perform the first update
        // Create and configure the LineChartView
               lineChartView = LineChartView()
               lineChartView.translatesAutoresizingMaskIntoConstraints = false

               // Add the LineChartView as a subview
               view.addSubview(lineChartView)

               // Configure constraints for the LineChartView
               NSLayoutConstraint.activate([
                   lineChartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                   lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                   lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                   lineChartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
               ])

               // Call the function to set up the line chart
               setupLineChart()
        timer2 = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updatePosition), userInfo: nil, repeats: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.isStartMeasure = true
        })
//        DispatchQueue.main.asyncAfter(deadline: .now() + 25, execute: {
//            UserDefaults.standard.set(self.beacon1, forKey: "RoomB-b1")
//            UserDefaults.standard.set(self.beacon2, forKey: "RoomB-b2")
//        })
    }
    var isStartMeasure = false
    var timer2: Timer?

    func setupLineChart() {
        // Create an array of data entries
    }
    
    @objc func addDataPoint() {
           // Create a data set from the updated data entries
           let dataSet = LineChartDataSet(entries: entries, label: "Xiaomi")
        let dataSet2 = LineChartDataSet(entries: entries2, label: "T20")

           // Customize the appearance of the data set
           dataSet.colors = [NSUIColor.blue]
           dataSet.circleColors = [NSUIColor.blue]
        
        dataSet2.colors = [NSUIColor.red]
        dataSet2.circleColors = [NSUIColor.red]

           // Create a data object from the updated data set
           let data = LineChartData(dataSets: [dataSet, dataSet2])

           // Set the updated data to the line chart view
           lineChartView.data = data

           // Notify the chart that the data has changed
           lineChartView.notifyDataSetChanged()
       }
    
    @objc func addDataPointReal() {
           // Create a data set from the updated data entries
           let dataSet = LineChartDataSet(entries: entries2, label: "REal")

           // Customize the appearance of the data set
           dataSet.colors = [NSUIColor.red]
           dataSet.circleColors = [NSUIColor.red]

           // Create a data object from the updated data set
           let data = LineChartData(dataSet: dataSet)

           // Set the updated data to the line chart view
           lineChartView.data = data

           // Notify the chart that the data has changed
           lineChartView.notifyDataSetChanged()
       }
    
    func measure() {
        var filter = KalmanFilter(stateEstimatePrior: 0, errorCovariancePrior: 1)
        
        for measurement in measurements {
            let prediction = filter.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0.1)
            let update = prediction.update(measurement: measurement, observationModel: 1, covarienceOfObservationNoise: 0.1)
            
            filter = update
            
        }
        print("f update=\(filter.stateEstimatePrior) err0r=\(filter.errorCovariancePrior)")
        guard filter.errorCovariancePrior > 0 else {
            return
        }
        entries.append(ChartDataEntry(x: Double((entries.count + 1)), y: filter.stateEstimatePrior))
        addDataPoint()
    }

    @objc func updateRSSIValues(_ timer: Timer) {
    }
    
    var _beacons: [CLBeacon] = []
    var beacon1: [Double] = []
    var beacon2: [Double] = []
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        _beacons = beacons
        
            for (index, beacon) in beacons.enumerated() {
           // measurements.append(Double(beacon.rssi))
            //print("f real=\(beacon.rssi) err0r=\(beacon.accuracy)")
            guard beacon.accuracy > 0 else {
                return
            }
                if beacon.major == 199 {
                entries.append(ChartDataEntry(x: Double((entries.count + 1)), y: Double(beacon.rssi)))
                addDataPoint()
                    if isStartMeasure {
                        beacon1.append(Double(beacon.rssi))
                    }
            } else {
                entries2.append(ChartDataEntry(x: Double((entries2.count + 1)), y: Double(beacon.rssi)))
                addDataPoint()
                if isStartMeasure {
                    beacon2.append(Double(beacon.rssi))
                }
            }
            
        }
        print("thond: \(beacons.first?.rssi) - \(beacons[1].rssi)")

//        measurements = Array(measurements.suffix(5))
//        measure()
        
    }
    
    @objc func updatePosition() {
        isStartMeasure = false
        let queryCounts = binRSSIValues(
            beacon1RSSI: beacon1.shuffled(),
            beacon2RSSI: beacon2.shuffled(),
            beacon3RSSI: beacon1.shuffled()
        )

        if let estimatedLocation = estimateLocationFromBins(beaconCounts: queryCounts) {
            print("Estimated Location: \(estimatedLocation)")
            positionLbl.text = estimatedLocation
        } else {
            positionLbl.text = "fail"
            print("Location estimation failed.")
        }
        beacon1.removeAll()
        beacon2.removeAll()
        isStartMeasure = true
    }
}

