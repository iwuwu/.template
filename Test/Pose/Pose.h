#pragma once

#include <Eigen/Dense>
#include <QtQml/qqml.h>

#include "./FiModule.h"

FI_CLASS Pose : public Eigen::Matrix4d {
  Q_GADGET
  QML_VALUE_TYPE(pose)

public:
    // // 默认构造：单位矩阵
    // Pose() : Eigen::Matrix4d(Eigen::Matrix4d::Identity()) {}
    // // 从基类矩阵构造
    // Pose(const Eigen::Matrix4d& matrix) : Eigen::Matrix4d(matrix) {}

public:
    Pose operator*(const Pose& other) const;
    // Pose operator/(const Pose& other) const;
  
public:
    // 计算旋转矩阵 R 的李代数 (轴角表示 phi = theta * n)
    static auto logSO3(const Eigen::Matrix3d& R) -> Eigen::Vector3d;

    // 计算向量 n 的叉积矩阵 [n]_\times
    static auto skewSymmetric(const Eigen::Vector3d& n) -> Eigen::Matrix3d;

    // 计算 SE(3) 的李代数 xi = [rho, phi]
    static auto logSE3(const Eigen::Matrix4d& T) -> Eigen::Matrix<double, 6, 1>;

    // 求位姿矩阵的李代数的模长
    static auto distance(const Eigen::Matrix4d &pose1, const Eigen::Matrix4d &pose2) -> double;

    //位姿矩阵转6D向量（Tx, Ty, Tz, radX, radY, radZ）[欧拉角(弧度制), 旋转顺序为 ZYX. 长度单位是米]
    static auto poseToVector(const Pose& pose) -> std::vector<double>;

    //6D向量转位姿矩阵[欧拉角(弧度制), 旋转顺序为 ZYX. 长度单位是米]
    static auto vectorToPose(const std::vector<double>& vector) -> Pose;

    // 获取单位矩阵
    //  static Pose Identity();

    //求逆
    Pose inverse();

  public:
    /// 将矩阵转为字符串(行优先).
    std::string toStdString(double accuracy = 0.0000000001) const;
    Q_INVOKABLE QString toQString(double accuracy = 0.0000000001) const;
}
FI_END

//TODO 实现隐式共享的位姿体系，包括SE3d，Rotation，Translation，可以直接就叫R或者T，