#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QFileDialog>
#include <iostream>
#include <stdio.h>
#include <QGraphicsScene>
#include <QGraphicsView>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

// Event listener for Printing contents of QList
void MainWindow::on_actionImport_images_triggered(){ printList(); }

// Event listener to clear QList containing filenames to be processed
void MainWindow::on_action_Debug_Clear_Stored_Images_triggered()
{
    clearList();
    QString placeholderImagePath = "C:\\Users\\Aphrodite\\Documents\\Imgpa\\Imgpa\\placeholder.jpg";
    QPixmap nullPix (placeholderImagePath);
    MainWindow::ui->label_1->setPixmap(nullPix.scaled(500,500, Qt::IgnoreAspectRatio, Qt::FastTransformation));
    MainWindow::ui->label_2->setPixmap(nullPix.scaled(500,500, Qt::IgnoreAspectRatio, Qt::FastTransformation));
}

// Event listener for Quit button
void MainWindow::on_actionQuit_triggered(){ exit(0); }

// Event Listener to add pictures using PushButtons
void MainWindow::on_pushButton1_clicked()
{
    // Open UI File Dialog to get input files
    QString fileName = QFileDialog::getOpenFileName(
                this,
                tr("Select Images"),
                cwdchar,
                tr("Image Files (*.png *.jpg *.jpeg *.tif)")
                );
    // Add filename to QList for later processing
    addToList(fileName);
    // Declare and create Pixmap
    QPixmap tempPix (fileName);
    // Set label to use Pixmap (W x H)
    ui->label_1->setPixmap(tempPix.scaled(500, 500, Qt::IgnoreAspectRatio, Qt::FastTransformation));
}

void MainWindow::on_pushButton2_clicked()
{
    // Open UI File Dialog to get input files  TODO: Make cwd dynamic
    QString fileName = QFileDialog::getOpenFileName(
                this,
                tr("Select Images"),
                cwdchar,
                tr("Image Files (*.png *.jpg *.jpeg *.tif)")
                );
    // Add filename to QList for later processing
    addToList(fileName);
    // Declare and create Pixmap
    QPixmap tempPix (fileName);
    // Set label to use Pixmap
    ui->label_2->setPixmap(tempPix.scaled(500, 500, Qt::IgnoreAspectRatio, Qt::FastTransformation));
}

// Use MATLAB script to process images and find circles in image
void MainWindow::on_pushButton_clicked()
{
    // Iterate through QList
    for(const auto& i : allFiles )
    {
        // Image filename
        std::string file = i.toStdString();
        // Program's directory
        std::string dir = "C:\\Users\\Aphrodite\\Documents\\Imgpa\\Imgpa\\";
        // MATLAB command string
        std::string MATLAB = "matlab -nodisplay -nosplash -nodesktop -r \"cd " + dir + ";detect('" + file +"');\"";
        // String to prepend to matlab command to open in separate CMD
        std::string cmd = "cmd /c start " + MATLAB;
        // Cast std::string command to const char
        const char * c = cmd.c_str();
        // Launch MATLAB script and pass file as argument
        system(c);
    }
}

