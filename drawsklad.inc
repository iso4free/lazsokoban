  if not CanDraw then Exit;
  case Sklad[aRow,aCol] of
' ':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//підлога
'#':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bWall.Picture.Bitmap);//стіна
'.':begin //ціль
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//спочатку малюємо підлогу
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlace.Picture.Bitmap);//тоді ціль
    end;
'@':begin //кладовщик
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//спочатку малюємо підлогу
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlayer.Picture.Bitmap);//тоді кладовщика
    end;
'+':begin //ккладовщик на цілі
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//спочатку підлога
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlace.Picture.Bitmap);//тоді ціль
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlayer.Picture.Bitmap);//і лише тоді кладовщика
    end;
'$':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bBox.Picture.Bitmap);//ящик
'*':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlacedBox.Picture.Bitmap);//ящик на цілі
  end;
