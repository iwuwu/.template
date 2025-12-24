#include "Pose.h"

// FI_DYNAMIC_TYPE

// FI_OPERATOR / (const Pose &other) const -> Pose {
//   return Pose(other.inverse() * *((Eigen::Matrix4d *)this));
// }

FI_OPERATOR *(const Pose &other) const -> Pose {
  return Pose((*((Eigen::Matrix4d *)this)) * (Eigen::Matrix4d)other);
}

// 计算旋转矩阵 R 的李代数 (轴角表示 phi = theta * n)
FI_METHOD logSO3(const Eigen::Matrix3d &R) -> Eigen::Vector3d
{
    double theta = std::acos((R.trace() - 1) / 2.0);
    
    // 处理 theta 为 0 或接近 0 的情况
    if (theta < 1e-10) {
        return Eigen::Vector3d::Zero();
    }
    
    Eigen::Vector3d n;
    n << R(2, 1) - R(1, 2),
         R(0, 2) - R(2, 0),
         R(1, 0) - R(0, 1);
    n = n / (2 * std::sin(theta));
    
    return theta * n;
}

// 计算向量 n 的叉积矩阵 [n]_\times
FI_METHOD skewSymmetric(const Eigen::Vector3d &n) -> Eigen::Matrix3d
{
    Eigen::Matrix3d S;
    S <<     0, -n(2),  n(1),
          n(2),     0, -n(0),
         -n(1),  n(0),     0;
    return S;
}

// 计算 SE(3) 的李代数 xi = [rho, phi]
FI_METHOD logSE3(const Eigen::Matrix4d &T) -> Eigen::Matrix<double, 6, 1>
{
    Eigen::Matrix3d R = T.block<3, 3>(0, 0);
    Eigen::Vector3d t = T.block<3, 1>(0, 3);
    Eigen::Vector3d phi = logSO3(R);

    // 计算平移部分 rho = J^{-1} * t
    Eigen::Vector3d rho;
    double theta = phi.norm();
    
    if (theta < 1e-10) {
        rho = t; // 当 theta=0 时，J = I
    } else {
        Eigen::Vector3d n = phi / theta;
        Eigen::Matrix3d J_inv = Eigen::Matrix3d::Identity() * theta / std::tan(theta / 2) 
                              + (1 - theta / std::tan(theta / 2)) * n * n.transpose() 
                              - theta / 2 * skewSymmetric(n);
        rho = J_inv * t;
    }

    Eigen::Matrix<double, 6, 1>  xi;
    xi << rho, phi;
    return xi;
}

// 求位姿矩阵的李代数的模长
// FI_METHOD distance(const Eigen::Matrix4d &pose1, const Eigen::Matrix4d &pose2) -> double
// {
//     return logSE3(pose1.inverse()*pose2).norm();
// }

//计算两个位姿原点的距离
FI_METHOD distance(const Eigen::Matrix4d &pose1, const Eigen::Matrix4d &pose2) -> double
{
    Eigen::Vector3d translation1 = pose1.block<3, 1>(0, 3);
    Eigen::Vector3d translation2 = pose2.block<3, 1>(0, 3);
    Eigen::Vector3d difference = translation2 - translation1;
    return difference.norm();
}

//位姿矩阵转6D向量（Tx, Ty, Tz, radX, radY, radZ）[欧拉角(弧度制), 旋转顺序为 ZYX. 长度单位是米]
FI_METHOD poseToVector(const Pose& pose) -> std::vector<double>
{
    Eigen::Vector<double, 6> vector;
    vector << pose.block<3, 1>(0, 3) , pose.block<3, 3>(0, 0).eulerAngles(2, 1, 0).reverse();
    std::vector<double> targetVec(vector.data(), vector.data() + vector.size());
    return targetVec;
}

//6D向量转位姿矩阵[欧拉角(弧度制), 旋转顺序为 ZYX. 长度单位是米]
FI_METHOD vectorToPose(const std::vector<double>& vector) -> Pose
{
    Pose pose = Pose(Pose::Identity());
    Eigen::AngleAxisd xAngle(vector[3], Eigen::Vector3d::UnitX());
    Eigen::AngleAxisd yAngle(vector[4], Eigen::Vector3d::UnitY());
    Eigen::AngleAxisd zAngle(vector[5], Eigen::Vector3d::UnitZ());
    pose.block<3, 3>(0, 0) = (zAngle * yAngle * xAngle).toRotationMatrix();
    pose.block<3, 1>(0, 3) << vector[0], vector[1], vector[2];
    return pose;
}

// FI_METHOD Identity() -> Pose{
//     return Pose(Eigen::Matrix4d::Identity());
// }

FI_METHOD
inverse() -> Pose {
  return Pose((*((Eigen::Matrix4d *)this)).inverse());
}

FI_METHOD Pose::toStdString(double accuracy) const -> std::string
{
    std::ostringstream strBuffer;
    for (int i = 0; i < 16; i++) {
        double element = (*((Eigen::Matrix4d *)this))(i / 4, i % 4);
        if (std::abs(element) < accuracy) {
            element = 0;
        }
        strBuffer << std::left << std::setw(10) << element;
        if (i < 15)
            strBuffer << ",";
        if (3 == i % 4)
            strBuffer << "\n";
    }
    return strBuffer.str();
}

FI_METHOD toQString(double accuracy) const -> QString {
//     Eigen::Vector3d translation = (*((Eigen::Matrix4d *)this)).block<3, 1>(0,
//     3); QString pose = QString::number(translation.x()) + " , " +
//                      QString::number(translation.y()) + " , " +
//                      QString::number(translation.z());
//   return pose;

  return QString(this->toStdString(accuracy).c_str());
}
