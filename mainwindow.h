#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QList>
#include <QString>
#include <iostream>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    // QList used for storage of image paths
    QList<QString> allFiles;

    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    // Current Working Directory (in String and char * formats)
    std::string cwd = "cd C:\\Users\\Aphrodite\\Documents\\Imgpa\\Imgpa\\";
    const char * cwdchar = cwd.c_str();

    /**
    * @brief Method for adding elements to QList
    * @param st File path to add to QList
    */
    void addToList(QString st){ allFiles.append(st); }

    // Prints QList
    void printList()
    {
        for(const auto& i : allFiles )
        {
            std::cout << i.toStdString() << std::endl;
        }
    }

    //Deletes all elements from QList
    void clearList(){ allFiles.clear(); }


private slots:
    // Print paths DEBUG method
    void on_actionImport_images_triggered();
    // Quit program
    void on_actionQuit_triggered();
    // Add image buttons
    void on_pushButton1_clicked();
    void on_pushButton2_clicked();
    // Process images
    void on_pushButton_clicked();
    // Clear paths DEBUG method
    void on_action_Debug_Clear_Stored_Images_triggered();

private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
