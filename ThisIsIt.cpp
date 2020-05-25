#include <opencv2\core.hpp>
#include <opencv2\highgui.hpp>
#include <opencv2\imgproc.hpp>
#include <iostream>

using namespace cv;
using namespace std;

struct features
{
	int contourIndex;
	int area;
	int perimeter;
	float circularity;
	float elongation;
};

void main()
{
	Mat img = imread("C:\\Users\\Chris\\Desktop\\Pictures for Project\\Testing\\test4.jfif");
	resize(img, img, Size(), 0.7, 0.7);
	Mat rangeImg = Mat(img.size(), CV_8U);
	Mat morphImg = Mat(img.size(), CV_8U);
	Mat contourImg = Mat(img.size(), CV_8UC3, Scalar(255, 255, 255));
	Mat blackImg = Mat(img.size(), CV_8UC3);
	Mat colourImg = Mat(img.size(), CV_8UC3);

	double c1 = 0;
	double c2 = 0;

	// Make White background black
	for (int x = 0; x < img.cols; x++) {
		for (int y = 0; y < img.rows; y++) {
			if (img.at<Vec3b>(Point(x, y))[0] > 230 && img.at<Vec3b>(Point(x, y))[1] > 230 && img.at<Vec3b>(Point(x, y))[2] > 230) {
				blackImg.at<Vec3b>(Point(x, y))[0] = 0;
				blackImg.at<Vec3b>(Point(x, y))[1] = 0;
				blackImg.at<Vec3b>(Point(x, y))[2] = 0;
				c1++;
			}
			else {
				blackImg.at<Vec3b>(Point(x, y))[0] = img.at<Vec3b>(Point(x, y))[0];
				blackImg.at<Vec3b>(Point(x, y))[1] = img.at<Vec3b>(Point(x, y))[1];
				blackImg.at<Vec3b>(Point(x, y))[2] = img.at<Vec3b>(Point(x, y))[2];
			}
			c2++;
		}
	}


	if ((c2 / c1) > 100) {
		cout << "Incorrect Input Structure" << endl;
		return;
	}

	// Threshhold the image to be black and white
	inRange(blackImg, Scalar(1, 1, 1), Scalar(255, 255, 255), rangeImg);

	Mat elem = getStructuringElement(MORPH_ELLIPSE, Size(8, 8));

	// Close the image. Dilation + Erosion
	morphologyEx(rangeImg, morphImg, MORPH_CLOSE, elem);
	medianBlur(morphImg, morphImg, 9);

	vector<vector<Point>> contours;
	vector<Vec4i> hierarchy;

	findContours(morphImg, contours, hierarchy, RETR_TREE, CHAIN_APPROX_NONE);

	int m = 0;
	for (int i = 0; i < contours.size(); i++) {
		if (hierarchy[i][3] == -1) {
			m++;
		}
	}

	int y = 0;
	int t = 0;
	while (m > 2) {
		m = 0;
		y++;
		Mat elem = getStructuringElement(MORPH_ELLIPSE, Size(8 + y, 8 + y));
		morphologyEx(rangeImg, morphImg, MORPH_CLOSE, elem);
		contours.clear();
		hierarchy.clear();
		findContours(morphImg, contours, hierarchy, RETR_TREE, CHAIN_APPROX_NONE);
		for (int i = 0; i < contours.size(); i++) {
			if (hierarchy[i][3] == -1) {
				m++;
			}
		}
		cout << "Iteration: " << y << endl;
		if (y > 6 && m > 2) {
			t = t + 5;
			if (t > 20) {
				cout << "Image could not be classified" << endl;
				return;
			}
			for (int x = 0; x < img.cols; x++) {
				for (int y = 0; y < img.rows; y++) {
					if (img.at<Vec3b>(Point(x, y))[0] > (230 + t) && img.at<Vec3b>(Point(x, y))[1] > (230 + t) && img.at<Vec3b>(Point(x, y))[2] > (230 + t)) {
						blackImg.at<Vec3b>(Point(x, y))[0] = 0;
						blackImg.at<Vec3b>(Point(x, y))[1] = 0;
						blackImg.at<Vec3b>(Point(x, y))[2] = 0;
					}
					else {
						blackImg.at<Vec3b>(Point(x, y))[0] = img.at<Vec3b>(Point(x, y))[0];
						blackImg.at<Vec3b>(Point(x, y))[1] = img.at<Vec3b>(Point(x, y))[1];
						blackImg.at<Vec3b>(Point(x, y))[2] = img.at<Vec3b>(Point(x, y))[2];
					}
				}
			}
			inRange(blackImg, Scalar(10, 10, 10), Scalar(255, 255, 255), rangeImg);
			cout << "Increasing Initial Thresholding Value Iteration: " << t / 5 << endl;
			medianBlur(rangeImg, morphImg, 5);
			y = 0;
		}
	}

	vector<features> featVec;
	float n = -1;

	for (int i = 0; i < contours.size(); i++) {
		if (hierarchy[i][3] == -1) {
			features f;
			f.contourIndex = i;
			f.area = contourArea(contours[i]);
			f.perimeter = arcLength(contours[i], true);
			f.circularity = (4 * 3.14 * f.area) / pow(f.perimeter, 2);
			RotatedRect box = minAreaRect(contours[i]);
			f.elongation = max(box.size.width / box.size.height, box.size.height / box.size.width);
			featVec.push_back(f);
			n++;
			Point2f rect_points[4];
			box.points(rect_points);
			string dog = "Dog";
			string human = "Human";
			if (featVec[n].elongation > 2.5) {
				for (int j = 0; j < 4; j++)
				{
					line(img, rect_points[j], rect_points[(j + 1) % 4], Scalar(0, 255, 0));
				}
				putText(img, human, rect_points[0], FONT_HERSHEY_SIMPLEX, 1, Scalar(0, 255, 0), 1, 8, false);
				drawContours(contourImg, contours, featVec[n].contourIndex, Scalar(0, 255, 0), 1);
			}
			else {
				for (int j = 0; j < 4; j++)
				{
					line(img, rect_points[j], rect_points[(j + 1) % 4], Scalar(0, 0, 255));
				}
				putText(img, dog, rect_points[3], FONT_HERSHEY_SIMPLEX, 1, Scalar(0, 0, 255), 1, 8, false);
				drawContours(contourImg, contours, featVec[n].contourIndex, Scalar(0, 0, 255), 1);
			}
		}
	}

	// Show the different images
	imshow("Img", img);
	imshow("Range", rangeImg);
	imshow("Morph", morphImg);
	imshow("Contours", contourImg);
	imshow("Black", blackImg);
	waitKey(0);
}