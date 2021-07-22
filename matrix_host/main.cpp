#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/features2d.hpp> 
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <fstream>
#include <vector>
#include <stddef.h>
#include <stdint.h>

#include "mem_one_frame.h"

#define MATRIX_SIZE 64

int main()
{   
    // Get the image 
    cv::Mat input = cv::imread("/home/alex/matrix/matrix_host/test_image/grad.jpg", cv::IMREAD_COLOR); 
    
    cv::flip(input,input,1);
    
    // Resize image
    cv::resize(input, input, cv::Size(64, 64));

    // Get rgb component
    std::vector<cv::Mat> rgb_vector;
    cv::split(input, rgb_vector);
    
    std::vector<uint64_t> buffer(1024,0);
    
    for (size_t i = 0; i < 1024; i++)
    {
        buffer[i] = 0x0;
    }
    
    mem(buffer,rgb_vector);
    
    sender_one_frame(buffer);

    printf("Succesfuly!\n");
    return 0;
}