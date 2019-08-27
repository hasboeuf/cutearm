#include <QCoreApplication>
#include <QTimer>
#include <QDebug>


int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    QTimer::singleShot(0, [&a]() {
        qDebug() << "Quit event loop";
        a.quit();
    });
    return a.exec();
}
